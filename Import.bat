@echo off
echo Importing BIOS settings...
SCEWIN_64.exe /O /S "%ProgramData%\warris\BIOSSettings.txt"
echo BIOS settings imported successfully.
