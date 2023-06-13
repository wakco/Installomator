Using a install direct script you can use the following script to run Installomator on the computers directly instead of keeping a copy within Jamf Pro/Cloud, allowing a more flexible approach to using Installomator, and not needing to worry so much about how jamf passes parameters.

The Install-with-swiftDialog.zsh script should be loaded into Jamf Pro/Cloud and needs the following options setup in the Options tab:

Parameter 4: Application (Installomator Label, or valuesfromarguments)
- Passed directly to Installomator, and used as the Application if not set.
Parameter 5: Full Readable Application Name (used in the window title and content, Defaults to Application)
- Passed to swiftDialog for display purposes only
Parameter 6: Icon (Default: Self Service icon)
- Passed to swiftDialog for display purposes only
Parameter 7: Notification level ( nodialogsilent, silent, nodialogsuccess, success, nodialogall, or Default: all)
- filtered before passing to Installomator, if nodialog is attached, swiftDialog is not used, nodialog is removed before passing to Installomator
Parameter 8: Remaining Installomator variables when using valuesfromarguments (should at least include name, type, downloadURL, and expectedTeamID)
