PROJECT = zooom3.xcodeproj
SCHEME = zooom3
APP_NAME = Zooom3
PLIST = zooom3/zooom3-Info.plist
BUILD_DIR = /tmp/zooom3-release

.PHONY: test build release clean

test:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) test

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) build

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean
	rm -rf $(BUILD_DIR)

release:
ifndef VERSION
	$(error VERSION is required. Usage: make release VERSION=x.y.z)
endif
	@echo "==> Bumping version to $(VERSION)"
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(VERSION)" $(PLIST)
	@echo "==> Building release"
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release clean build SYMROOT=$(BUILD_DIR)
	@echo "==> Zipping $(APP_NAME).app"
	cd $(BUILD_DIR)/Release && zip -r $(BUILD_DIR)/$(APP_NAME)-v$(VERSION).zip $(APP_NAME).app
	@echo "==> Committing and tagging v$(VERSION)"
	git add $(PLIST)
	git commit -m "Bump version to $(VERSION)"
	git tag v$(VERSION)
	git push origin main v$(VERSION)
	@echo "==> Creating GitHub release"
	gh release create v$(VERSION) $(BUILD_DIR)/$(APP_NAME)-v$(VERSION).zip \
		--title "$(APP_NAME) v$(VERSION)" \
		--notes "Release $(APP_NAME) v$(VERSION)"
	@echo "==> Released $(APP_NAME) v$(VERSION)"
