# ZazzyChat AppImage

ZazzyChat is provided as AppImage too. To Download, visit zazzychat.im.

## Building

- Ensure you install `appimagetool`

```shell
flutter build linux

# copy binaries to appimage dir
cp -r build/linux/{x64,arm64}/release/bundle appimage/ZazzyChat.AppDir
cd appimage

# prepare AppImage files
cp ZazzyChat.desktop ZazzyChat.AppDir/
mkdir -p ZazzyChat.AppDir/usr/share/icons
cp ../assets/logo.svg ZazzyChat.AppDir/zazzychat.svg
cp AppRun ZazzyChat.AppDir

# build the AppImage
appimagetool ZazzyChat.AppDir
```
