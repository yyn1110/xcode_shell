plist=${PROJECT_DIR}/${INFOPLIST_FILE}
pyfile=${SRCROOT}/Miao.py
python ${pyfile}
if [ $CONFIGURATION == Release ]; then
echo "Bumping build number..."


buildnum=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${plist}")
if [[ "${buildnum}" == "" ]]; then
echo "No build number in $plist"
exit 2
fi

buildnum=$(expr $buildnum + 1)
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $buildnum" "${plist}"
echo "Bumped build number to ${buildnum}"


buildEnvDocSwitch=$(/usr/libexec/PlistBuddy -c "Print UIFileSharingEnabled" "${plist}")
if [ "X${buildEnvDocSwitch}" == "Xtrue" ]; then
buildEnvDocSwitch="false"
/usr/libexec/Plistbuddy -c "Set UIFileSharingEnabled $buildEnvDocSwitch" "${plist}"
fi


else
echo "debug "
fi