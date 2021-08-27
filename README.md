## macOS build

```shell
$ cd macos && pod install
$ make build-macos
$ codesign -d --entitlements :- build/macos/Build/Products/Release/flutter_vlc_demo.app # check
$ open -a $PWD/build/macos/Build/Products/Release/flutter_vlc_demo.app
```
## Fedora Silverblue build

```shell
$ toolbox enter
$ sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
$ sudo dnf install vlc-devel gtk3-devel mesa-dri-drivers
$ make build-flatpak
$ flatpak --user install ./build/linux/flatpak/flutter_vlc_demo.flatpak
$ flatpak run com.github.birros.FlutterVLCDemo
```

## iOS build

```shell
$ cd io && pod install
$ make build-ipa
$ # install it with https://github.com/rileytestut/AltStore
```

## Android build

```shell
$ make build-apk
```
