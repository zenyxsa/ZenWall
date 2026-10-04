cmake_minimum_required(VERSION 3.21)
project(ZenWall VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Qml Multimedia)

qt_policy(SET QTP0004 NEW)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(zenwall_app
    src/main.cpp
    src/WallpaperBackend.cpp
    src/WallpaperBackend.h
)

qt_add_qml_module(zenwall_app
    URI ZenWall
    VERSION 1.0
    QML_FILES
        src/Main.qml
        src/SkewView.qml
        src/SkewCard.qml
        src/TopBar.qml
        src/SkewBarButton.qml
)

set_target_properties(zenwall_app PROPERTIES
    OUTPUT_NAME "zenwall"
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(zenwall_app PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::Multimedia
)

if(WIN32)
    target_link_libraries(zenwall_app PRIVATE ole32 user32)
endif()
