#!/usr/bin/env bash
git apply ./scripts/enable-android-google-services.patch
ZAZZYCHAT_ORIG_GROUP="im.zazzychat"
ZAZZYCHAT_ORIG_TEAM="4NXF6Z997G"
#ZAZZYCHAT_NEW_GROUP="com.example.zazzychat"
#ZAZZYCHAT_NEW_TEAM="ABCDE12345"

# In some cases (ie: running beta XCode releases) some pods haven't updated their minimum version
# but XCode will reject the package for using too old of a minimum version. 
# This will fix that, but. Well. Use at your own risk.
# export I_PROMISE_IM_REALLY_SMART=1

# If you want to automatically install the app
# export ZAZZYCHAT_INSTALL_IPA=1

### Rotate IDs ###
[ -n "${ZAZZYCHAT_NEW_GROUP}" ] && {
	# App group IDs
	sed -i "" "s/group.${ZAZZYCHAT_ORIG_GROUP}.app/group.${ZAZZYCHAT_NEW_GROUP}.app/g" "macos/Runner/Runner.entitlements"
	sed -i "" "s/group.${ZAZZYCHAT_ORIG_GROUP}.app/group.${ZAZZYCHAT_NEW_GROUP}.app/g" "macos/Runner.xcodeproj/project.pbxproj"
	# Bundle identifiers
	sed -i "" "s/${ZAZZYCHAT_ORIG_GROUP}.app/${ZAZZYCHAT_NEW_GROUP}.app/g" "macos/Runner.xcodeproj/project.pbxproj"
}

[ -n "${ZAZZYCHAT_NEW_TEAM}" ] && {
	# Code signing team
	sed -i "" "s/${ZAZZYCHAT_ORIG_TEAM}/${ZAZZYCHAT_NEW_TEAM}/g" "macos/Runner.xcodeproj/project.pbxproj"
}

### Make release build ###
flutter build macos --release

echo "Build build/macos/Build/Products/Release/ZazzyChat.app"
