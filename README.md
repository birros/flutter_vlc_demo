## macOS build

```shell
$ cd macos && pod install
$ flutter build macos --release
$ codesign -d --entitlements :- build/macos/Build/Products/Release/flutter_vlc_demo.app # check
$ open -a $PWD/build/macos/Build/Products/Release/flutter_vlc_demo.app
```
## Fedora Silverblue build

```shell
$ toolbox enter
$ sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
$ sudo dnf install vlc-devel gtk3-devel mesa-dri-drivers
$ flutter build linux --release
$ cd build-aux/flatpak && \
    flatpak-builder --force-clean --repo=repo builddir com.github.birros.FlutterVLCDemo.json && \
    flatpak build-bundle repo flutter_vlc_demo.flatpak com.github.birros.FlutterVLCDemo
$ flatpak --user install ./build-aux/flatpak/flutter_vlc_demo.flatpak
$ flatpak run com.github.birros.FlutterVLCDemo
```

## iOS build

```shell
$ flutter build ipa --release --export-options-plist=./ios/ExportOptions.plist
$ # install it with https://github.com/rileytestut/AltStore
```
