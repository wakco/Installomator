#!/bin/zsh

echo "$(date): Manage Installomator - Started"
installomator="/usr/local/Installomator/Installomator.sh"
dialogApp="/usr/local/bin/dialog"
JAMF="/usr/local/bin/jamf"
dialog_command_file="/var/tmp/dialog-$$.log"

# Checking Installomator and swiftDialog are installed.
if [ ! -e "$installomator" ]; then
 "$JAMF" policy -event InstallInstallomator # custom event, change this to the name of the install direct policy for Installomator.
fi
if [ ! -e "$dialogApp" ]; then
 "$installomator" swiftDialog NOTIFY=silent
fi

# Parameter 4: installomator label
if [ "$4" = "" ] || [ "$4" = "valuesfromarguments" ] && [[ "$8" = *"name="* ]] && [[ "$8" = *"type="* ]] && [[ "$8" = *"downloadURL="* ]] && [[ "$8" = *"expectedTeamID="* ]]; then
 echo "$(date): Error, what is Installomator installing?!? (valuesfromarguements requires name, type, downloadURL, and expectedTeamID)"
 exit 1
fi
installLabel="$4"

# Parameter 5: message displayed over the progress bar
message=${5:-"$4"}

# Parameter 6: path or URL to an icon
icon=${6:-"/Applications/Self Service.app/Contents/Resources/AppIcon.icns"}
# see Dan Snelson's advice on how to get a URL to an icon in Self Service
# https://rumble.com/v119x6y-harvesting-self-service-icons.html

# Parameter 7: notify level
notify=$(echo "${7:-"all"}" | tr "[:upper:]" "[:lower:]")

dialogUpdate() {
    # $1: dialog command
    local dcommand="$1"

    if [[ -n $dialog_command_file ]]; then
        echo "$dcommand" >> "$dialog_command_file"
        echo "Dialog: $dcommand"
    fi
}

# Using the Self Service icon for the overlay icon. Change this to an icon you want to see on all installs.
overlayicon="/Applications/Self Service.app/Contents/Resources/AppIcon.icns"

# Only display progress 
case "$notify" in
 nodialogsilent|nodialogsuccess|nodialogall)
  echo "$(date): $notify selected, skipping dialog."
  # removing nodialog from the setting for Installomator
  notify="$(echo "$notify" | cut -d "g" -f 2)"
 ;;
 silent|success|all)
 echo "$(date): $notify selected, starting dialog with launchctl asuser."
  # display screen as user
  /bin/launchctl asuser "$(id -u $3)" "$dialogApp" \
        --title "$message Progress..." \
        --icon "$icon" \
        --overlayicon "$overlayicon" \
        --message "Using Installomator to download & install (or update) $message." \
        --mini \
        --progress 100 \
        --position bottomright \
        --moveable \
        --commandfile "$dialog_command_file" &
  dialogPID="$!"
 ;;
 *)
  echo "$(date): Error, what is $notify?!?"
  exit 1
esac

# give everything a moment to catch up
sleep 0.1

# Let the install begin...
if [ ! "$8" = "" ]; then # while intended for valuesfromarguments, there may come the odd time when a manual addition is required
 installLabel="$installLabel $8"
fi

eval "$installomator $installLabel \"LOGO=$icon\" NOTIFY=$notify DIALOG_CMD_FILE=$dialog_command_file"

# close and quit dialog
dialogUpdate "progress: complete"
dialogUpdate "progresstext: Done"

# pause a moment
sleep 0.5

dialogUpdate "quit:"

# let everything catch up
sleep 0.5

# just in case
kill -9 $dialogPID

# Logging the command file
echo "$(date): Logging command file and removing it."
cat $dialog_command_file

# And cleanup
rm -f $dialog_command_file

echo "$(date): Manage Installomator - Finished"
# the killall command above will return error when Dialog is already quit
# but we don't want that to register as a failure in Jamf,  so always exit 0
exit 0
