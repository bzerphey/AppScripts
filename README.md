# AppScripts

## Description
<p> These scripts have been created to automate the app install for Telecom and her MSP customers.</p>

## Instructions

### Automate
1. Create a new script under Telecom Scripts>Software Installs.
2. Name the script "App Prettyname" vX.X.X - Install/Uninstall/Update.
3. Add a download task under the <b>Then</b> section.
4. Add a Shell function using the following syntact: 
```
powershell.exe -executionpolicy bypass .\Install.ps1 -file "InstallFileName" -name "AppName" -version "AppVersion" -switch "AlternativeSwitches:Optional"
```

## Tasks
- [x] Build install script.
- [ ] Build uninstall script.
- [ ] Build update script.
- [ ] Add instructions for creating Intune App.
- [ ] Add instructions for creating Automate App.
- [ ] Plan version 2.