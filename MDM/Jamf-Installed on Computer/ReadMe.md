<!-- large portions copied from the other Jamf folder -->

# Display Installomator Progress with SwiftDialog in Jamf

Installomator 10 has functionality to communicate with [Bart Reardon's swiftDialog](https://github.com/bartreardon/swiftDialog). However, you have to launch and setup swiftDialog to display a window with a progress bar before Installomator launches and also make sure swiftDialog quits after Installomator has run.

Here is an example script that combines the swiftDialog scripts in the Jamf folder, into a single script, removing the need for tracking the dialog command file across scripts, and uses a unique filename to avoid conflicts with other uses of swiftDialog.

## Initial Setup in Jamf Pro

This requires a policy in Jamf Pro/Cloud uses an install direct script (from the MDM folder) with a custom event name for this script to use. If looking for a suggestion for a custom event name, you could set it to `InstallInstallomator`, and therefore not need to change line 11 (as below).

The `Install-with-swiftDialog.zsh` script should be loaded into Jamf Pro/Cloud with the following two lines changed:
Line 11 contains a policy custom event name that should be changed to match custom event name of the policy being used to install and/or update Installomator (as above).
Line 45 contains the overlay icon for swiftDialog, this should be an icon that should appear everytime this script is used, the one in the script is the Self Service icon, so if the script is triggered without an icon for the app, it'll show the Self Service icon overlaying itself.

Add the following information to the **Parameter Values** in the **Options** tab (for a reminder when setting up policies that use this script):

**Parameter 4:** Application (Installomator Label, or valuesfromarguments)
- Passed to Installomator, and used as the Application if not set.

**Parameter 5:** Full Readable Application Name (used in the window title and content, Defaults to Application)
- Passed to swiftDialog for display purposes only.

**Parameter 6:** Icon (Default: Self Service icon)
- Passed to swiftDialog for display purposes only.

**Parameter 7:** Notification level ( nodialogsilent, silent, nodialogsuccess, success, nodialogall, or Default: all)
- filtered before passing to Installomator, if nodialog is attached, swiftDialog is not used, nodialog is removed before passing to Installomator

**Parameter 8:** Remaining Installomator variables when using valuesfromarguments (should at least include name, type, downloadURL, and expectedTeamID)
- This should also be used for things like `INSTALL=force`.

This works best with Self Service policies, but can also help with managing all executions of Installomator, as opposed to using **Files and Processes** to **Execute Command** `/usr/local/Installomator/Installomator.sh` ...

The script will confirm both Installomator and swiftDialog are installed, installing them if not (through a Jamf policy for Installomator, and silently with Installomator for swiftDialog), before configuring and displaying a swiftDialog dialog (if configured). `Installomator.sh` will download and install the app while writing update commands to the dialog command file `Install-with-swiftDialog.zsh` creates. `Install-with-swiftDialog.zsh` removes the dialog command file once finished.

Policies can now be created and personalised to each app by adding this script and configuring as needed.
