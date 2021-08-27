.PHONY: build-flatpak
build-flatpak:
	flutter build linux --release
	flatpak-builder \
		--state-dir=./build/linux/flatpak/.flatpak-builder \
		--force-clean \
		--ccache \
		--repo=./build/linux/flatpak/repo \
		./build/linux/flatpak/builddir \
		./linux/flatpak/com.github.birros.FlutterVLCDemo.json
	flatpak build-bundle \
		./build/linux/flatpak/repo \
		./build/linux/flatpak/flutter_vlc_demo.flatpak \
		com.github.birros.FlutterVLCDemo

.PHONY: build-ipa
build-ipa:
	flutter build ipa --release --export-options-plist=./ios/ExportOptions.plist

.PHONY: build-apk
build-apk:
	flutter build apk --release

.PHONY: build-macos
build-macos:
	flutter build macos --release
