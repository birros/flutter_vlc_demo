## macOS build

```shell
$ flutter build macos --release
$ codesign -d --entitlements :- build/macos/Build/Products/Release/flutter_vlc_demo.app # check
$ open -a $PWD/build/macos/Build/Products/Release/flutter_vlc_demo.app
```
