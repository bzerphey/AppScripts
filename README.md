# AppScripts

## Description
<p> These scripts have been created to automate the app install for Telecom and her MSP customers.</p>

## Install Instructions

#### Automate
1. Create a new script under Telecom Scripts>Software Installs.
2. Name the script "App Prettyname" vX.X.X - (Install/Uninstall/Update).
3. Add a download task under the <b>Then</b> section for the scripts. This should download to C:\Windows\LTSvc\packages. The download link is: https://raw.githubusercontent.com/bzerphey/AppScripts/main/Install.ps1 
4. You must create a link for the install files unless the vendor allows pulling from them directly. This can pull from https://telecombusiness.ftphosting.net/ (with instructions below) or directly from the vendor source.  
   - You must first create a share link.
   - Next go to the share link and copy the download link of the file you need to download.
   - Use curl to download.
5. Add a Shell function using the following syntact: 
```
powershell.exe -executionpolicy bypass C:\Windows\LTsvc\packages\Install.ps1 -file 'InstallFileName' -name 'AppName' -version 'AppVersion' -fileDL 'LinktoDownload' -switch 'AlternativeSwitches:Optional'
```
1. On line 3, add a Resend Software task.
2. On line 4, add IF SOFTWARE INSTALLED THEN Jump to line 6.
3. On line 5, add Script Exit with Error.
4. On line 6, add an exit script.
5.  If script ends in error, go to C:\TBSI_Repo\Install_'Program'.log via the file explorer tool in Automate to find the error.

#### Intune
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

[Tested Apps](TestedApps.md)

## Tasks
- [ ] Build install script.
  - [x] C:\TBSI_Repo folder check logic.
  - [x] Create download logic for install files.
  - [x] Create Log file. 
  - [x] Add preflight. **Needs tested**
  - [ ] Fix if logic for MSI
  - [x] Point Automate to pull script from GitHub
  - [x] ~~Add a return for Automate logging.~~ Built in logger that creates logs file on computer.
  - [x] Add script cleanup logic **Needs tested**
  - [ ] Turn off logging for the Automate script or build 2 scripts.
  - [x] Add follow-up task param and logic. Script will be unique. **Needs tested**
  - [ ] Create exit function to include cleanup.
- [ ] Build uninstall script.
  - [x] Build folder creation logic.
  - [x] Build function to search registry for uninstall string. **Needs tested**
  - [x] Build function to accept uninstall string from param. **Needs tested**
  - [ ] Add version checking to RegSearch.
  - [ ] Add script cleanup logic.
- [ ] Build update script.
- [ ] Finish instructions for creating Intune App. Maybe a separate script to call install.ps1?
- [ ] Finish instructions for creating Automate App.
- [ ] Plan version 2 with modules.