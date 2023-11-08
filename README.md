# AppScripts

## Description
<p> These scripts have been created to automate the app install for Telecom and her MSP customers.</p>

## Instructions

### Automate
1. Create a new script under Telecom Scripts>Software Installs.
2. Name the script "App Prettyname" vX.X.X - (Install/Uninstall/Update).
3. Add a download task under the <b>Then</b> section for the scripts. The download link is: https://raw.githubusercontent.com/bzerphey/AppScripts/main/Install.ps1 
4. You must create a separate link for the install files unless the vendor allows pulling from them directly. This should pull from https://telecombusiness.ftphosting.net/.
   - You must first create a share link.
   - Next go to the share link and copy the download link of the file you need to download.
   - Use curl to download.
5. Add a Shell function using the following syntact: 
```
powershell.exe -executionpolicy bypass .\Install.ps1 -file 'InstallFileName' -name 'AppName' -version 'AppVersion' -fileDL 'LinktoDownload' -switch 'AlternativeSwitches:Optional'
```
6. On line 3, add a Resend Software task.
7. On line 4, add IF SOFTWARE INSTALLED THEN Jump to line 6.
8. On line 5, add Script Exit with Error.
9. On line 6, add an exit script.
10. If script ends in error, go to C:\TBSI_Repo\Install_'Program'.log via the file explorer tool in Automate to find the error.

### Intune
1. Create folder with scripts and install file.
2. Run packaging command:
```
IntuneWinAppUtilexe -c "RootFolderWithScriptsandFiles"-s "FullPathToInstallScript" -o "DestinationFolder" -q
```
3. Create new Intune app.
4. Use the following for the install command:
```
powershell.exe -executionpolicy bypass .\Install.ps1 -file 'InstallFileName' -name 'AppName' -version 'AppVersion' -fileDL 'LinktoDownload' -switch 'AlternativeSwitches:Optional'
```
5. Use the following for the uninstall command:
```
Coming Soon....
```
6. Instructions for detection rules. Coming Soon....


## Tasks
- [ ] Build install script.
  - [x] C:\TBSI_Repo folder check logic.
  - [x] Create download logic for install files.
  - [x] Create Log file. 
  - [ ] Fix if logic for MSI
  - [x] Point Automate to pull script from GitHub
  - [ ] Add a return for Automate logging.
  - [ ] Add cleanup logic
- [ ] Build uninstall script.
- [ ] Build update script.
- [ ] Finish instructions for creating Intune App.
- [ ] Finish instructions for creating Automate App.
- [ ] Plan version 2 with modules.