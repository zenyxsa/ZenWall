#pragma once

#include <QObject>
#include <QString>
#include <QStringList>

class WallpaperBackend : public QObject
{
    Q_OBJECT

public:
    explicit WallpaperBackend(QObject *parent = nullptr);

    Q_INVOKABLE bool apply(const QString &path);
    Q_INVOKABLE bool applyToOutput(const QString &path, const QString &output);
    Q_INVOKABLE QString errorString() const;
    Q_INVOKABLE QStringList screenNames() const;
    Q_INVOKABLE int hueForFile(const QString &path);
    Q_INVOKABLE bool isFavorite(const QString &path) const;
    Q_INVOKABLE bool toggleFavorite(const QString &path);

signals:
    void favoritesChanged();

private:
    QString normalizedPath(const QString &path) const;
    bool ensureAwwwDaemon();

    QString m_error;
};
