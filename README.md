# AppScripts

## Description
<p> These scripts have been created to automate the app install for Telecom and her MSP customers.</p>

## Instructions

### Automate
1. Create a new script under Telecom Scripts>Software Installs.
2. Name the script "App Prettyname" vX.X.X - (Install/Uninstall/Update).
3. Add a download task under the <b>Then</b> section.
4. Add a Shell function using the following syntact: 
```
powershell.exe -executionpolicy bypass .\Install.ps1 -file "InstallFileName" -name "AppName" -version "AppVersion" -switch "AlternativeSwitches:Optional"
```

### Intune
1. Create folder with scripts and install file.
2. Run packaging command:
```
IntuneWinAppUtilexe -c "RootFolderWithScriptsandFiles"-s "FullPathToInstallScript" -o "DestinationFolder" -q
```
3. Create new Intune app.
4. Use the following for the install command:
```
powershell.exe -executionpolicy bypass .\Install.ps1 -file "InstallFileName" -name "AppName" -version "AppVersion" -switch "AlternativeSwitches:Optional"
```
5. Use the following for the uninstall command:
```
Coming Soon....
```
6. Instructions for detection rules. Coming Soon....


## Tasks
- [x] Build install script.
- [ ] Build uninstall script.
- [ ] Build update script.
- [x] Add instructions for creating Intune App.
- [x] Add instructions for creating Automate App.
- [ ] Finish instructions.
- [ ] Plan version 2.