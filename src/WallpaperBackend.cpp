#include "WallpaperBackend.h"

#include <QFileInfo>
#include <QProcess>
#include <QStandardPaths>
#include <QUrl>
#include <QSettings>
#include <QImageReader>
#include <QColor>
#include <QDir>
#include <QGuiApplication>
#include <QScreen>
#include <QThread>

#ifdef Q_OS_WIN
#include <windows.h>
#include <shobjidl_core.h>
#include <string>
#endif

WallpaperBackend::WallpaperBackend(QObject *parent)
    : QObject(parent)
{
}

QString WallpaperBackend::normalizedPath(const QString &path) const
{
    QString result = path;

    if (result.startsWith("file://"))
        result = QUrl(result).toLocalFile();

    return QDir::cleanPath(QFileInfo(result).absoluteFilePath());
}

QString WallpaperBackend::errorString() const
{
    return m_error;
}

QStringList WallpaperBackend::screenNames() const
{
#ifdef Q_OS_WIN
    QStringList result;

    for (DWORD index = 0;; ++index) {
        DISPLAY_DEVICEW device{};
        device.cb = sizeof(device);

        if (!EnumDisplayDevicesW(nullptr, index, &device, 0))
            break;

        if (!(device.StateFlags & DISPLAY_DEVICE_ACTIVE))
            continue;

        QString name =
            QString::fromWCharArray(device.DeviceName).trimmed();

        if (name.startsWith("\\\\.\\"))
            name = name.mid(4);

        if (!name.isEmpty())
            result.append(name);
    }

    return result;
#else
    QStringList result;

    for (QScreen *screen : QGuiApplication::screens()) {
        if (screen && !screen->name().isEmpty())
            result.append(screen->name());
    }

    return result;
#endif
}

bool WallpaperBackend::ensureAwwwDaemon()
{
#ifdef Q_OS_WIN
    return false;
#else
    const QString awww =
        QStandardPaths::findExecutable("awww");

    const QString daemon =
        QStandardPaths::findExecutable("awww-daemon");

    if (awww.isEmpty() || daemon.isEmpty()) {
        m_error =
            "awww and awww-daemon must both be installed.";
        return false;
    }

    QProcess probe;
    probe.start(awww, {"query"});

    if (probe.waitForStarted(1500)) {
        probe.waitForFinished(3000);

        if (probe.exitStatus() == QProcess::NormalExit &&
            probe.exitCode() == 0) {
            return true;
        }
    }

    if (!QProcess::startDetached(daemon, {})) {
        m_error = "Could not start awww-daemon.";
        return false;
    }

    QThread::msleep(400);

    QProcess retry;
    retry.start(awww, {"query"});

    if (retry.waitForStarted(1500)) {
        retry.waitForFinished(3000);

        if (retry.exitStatus() == QProcess::NormalExit &&
            retry.exitCode() == 0) {
            return true;
        }
    }

    m_error =
        "awww-daemon could not be started or is not responding.";

    return false;
#endif
}

bool WallpaperBackend::apply(const QString &path)
{
    return applyToOutput(path, QString());
}

bool WallpaperBackend::applyToOutput(
    const QString &path,
    const QString &output)
{
    m_error.clear();

    const QString cleanPath =
        normalizedPath(path);

    if (!QFileInfo::exists(cleanPath)) {
        m_error =
            "Wallpaper file does not exist: " +
            cleanPath;
        return false;
    }

#ifdef Q_OS_WIN

    HRESULT initResult =
        CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    const bool shouldUninitialize =
        SUCCEEDED(initResult);

    if (FAILED(initResult) &&
        initResult != RPC_E_CHANGED_MODE) {
        m_error =
            "Windows COM initialization failed.";

        return false;
    }

    IDesktopWallpaper *desktopWallpaper = nullptr;

    HRESULT hr =
        CoCreateInstance(
            CLSID_DesktopWallpaper,
            nullptr,
            CLSCTX_ALL,
            IID_PPV_ARGS(&desktopWallpaper));

    if (FAILED(hr) || !desktopWallpaper) {
        m_error =
            "Windows Desktop Wallpaper API could not be initialized.";

        if (shouldUninitialize)
            CoUninitialize();

        return false;
    }

    const std::wstring widePath =
        cleanPath.toStdWString();

    std::wstring targetMonitorId;

    if (!output.isEmpty() &&
        output.compare("ALL", Qt::CaseInsensitive) != 0) {

        QString nativeOutput = output.trimmed();

        if (!nativeOutput.startsWith("\\\\.\\"))
            nativeOutput = "\\\\.\\" + nativeOutput;

        struct DisplayLookup {
            std::wstring requested;
            RECT rect{};
            bool found = false;
        };

        DisplayLookup lookup{
            nativeOutput.toStdWString()
        };

        EnumDisplayMonitors(
            nullptr,
            nullptr,
            [](HMONITOR monitor,
               HDC,
               LPRECT,
               LPARAM data) -> BOOL {

                auto *lookup =
                    reinterpret_cast<DisplayLookup *>(data);

                MONITORINFOEXW info{};
                info.cbSize = sizeof(info);

                if (!GetMonitorInfoW(
                        monitor,
                        &info))
                    return TRUE;

                if (_wcsicmp(
                        info.szDevice,
                        lookup->requested.c_str()) == 0) {

                    lookup->rect =
                        info.rcMonitor;

                    lookup->found = true;

                    return FALSE;
                }

                return TRUE;
            },
            reinterpret_cast<LPARAM>(&lookup)
        );

        if (!lookup.found) {
            m_error =
                "Windows monitor not found: " +
                output;

            desktopWallpaper->Release();

            if (shouldUninitialize)
                CoUninitialize();

            return false;
        }

        UINT monitorCount = 0;

        hr =
            desktopWallpaper->GetMonitorDevicePathCount(
                &monitorCount);

        if (FAILED(hr)) {
            m_error =
                "Could not enumerate Windows monitors.";

            desktopWallpaper->Release();

            if (shouldUninitialize)
                CoUninitialize();

            return false;
        }

        for (UINT i = 0; i < monitorCount; ++i) {
            PWSTR monitorId = nullptr;

            hr =
                desktopWallpaper->GetMonitorDevicePathAt(
                    i,
                    &monitorId);

            if (FAILED(hr) || !monitorId)
                continue;

            RECT monitorRect{};

            HRESULT rectHr =
                desktopWallpaper->GetMonitorRECT(
                    monitorId,
                    &monitorRect);

            if (SUCCEEDED(rectHr) &&
                monitorRect.left == lookup.rect.left &&
                monitorRect.top == lookup.rect.top &&
                monitorRect.right == lookup.rect.right &&
                monitorRect.bottom == lookup.rect.bottom) {

                targetMonitorId =
                    std::wstring(monitorId);

                CoTaskMemFree(monitorId);
                break;
            }

            CoTaskMemFree(monitorId);
        }

        if (targetMonitorId.empty()) {
            m_error =
                "Could not resolve Windows monitor ID for " +
                output;

            desktopWallpaper->Release();

            if (shouldUninitialize)
                CoUninitialize();

            return false;
        }
    }

    // Keep Windows wallpapers using a crop/fill presentation.
    desktopWallpaper->SetPosition(DWPOS_FILL);

    hr =
        desktopWallpaper->SetWallpaper(
            targetMonitorId.empty()
                ? nullptr
                : targetMonitorId.c_str(),
            widePath.c_str());

    desktopWallpaper->Release();

    if (shouldUninitialize)
        CoUninitialize();

    if (SUCCEEDED(hr))
        return true;

    m_error =
        "Windows could not set the wallpaper (HRESULT 0x" +
        QString::number(
            static_cast<unsigned long>(hr),
            16) +
        ").";

    return false;

#else

    if (!ensureAwwwDaemon())
        return false;

    const QString awww =
        QStandardPaths::findExecutable("awww");

    QStringList args;

    args << "img";
    args << cleanPath;

    if (!output.isEmpty()) {
        args << "--outputs";
        args << output;
    }

    args << "--resize" << "crop";
    args << "--transition-type" << "any";
    args << "--transition-duration" << "0.8";
    args << "--transition-fps" << "60";

    QProcess process;

    process.start(awww, args);

    if (!process.waitForStarted(2000)) {
        m_error =
            "awww could not be started.";
        return false;
    }

    process.waitForFinished(10000);

    if (process.exitStatus() == QProcess::NormalExit &&
        process.exitCode() == 0) {
        return true;
    }

    const QString stderrText =
        QString::fromLocal8Bit(
            process.readAllStandardError()
        ).trimmed();

    m_error = stderrText.isEmpty()
        ? "awww failed to apply the wallpaper."
        : stderrText;

    return false;

#endif
}

int WallpaperBackend::hueForFile(
    const QString &path)
{
    const QString cleanPath =
        normalizedPath(path);

    QImageReader reader(cleanPath);
    reader.setAutoTransform(true);
    reader.setScaledSize(QSize(1, 1));

    const QImage image = reader.read();

    if (image.isNull())
        return -1;

    const QColor color =
        QColor::fromRgb(
            image.convertToFormat(
                QImage::Format_RGB32
            ).pixel(0, 0)
        );

    const int hue = color.hsvHue();

    if (hue < 0)
        return 99;

    if (color.saturationF() <= 0.12 ||
        color.lightnessF() <= 0.08 ||
        color.lightnessF() >= 0.92) {
        return 99;
    }

    return (hue / 30) % 12;
}

bool WallpaperBackend::isFavorite(
    const QString &path) const
{
    QSettings settings(
        "ZenWall",
        "ZenWall"
    );

    const QString key =
        normalizedPath(path);

    const QStringList favorites =
        settings.value(
            "favorites"
        ).toStringList();

    return favorites.contains(key);
}

bool WallpaperBackend::toggleFavorite(
    const QString &path)
{
    QSettings settings(
        "ZenWall",
        "ZenWall"
    );

    const QString key =
        normalizedPath(path);

    QStringList favorites =
        settings.value(
            "favorites"
        ).toStringList();

    const bool nowFavorite =
        !favorites.contains(key);

    if (nowFavorite)
        favorites.append(key);
    else
        favorites.removeAll(key);

    settings.setValue(
        "favorites",
        favorites
    );

    settings.sync();

    emit favoritesChanged();

    return nowFavorite;
}
