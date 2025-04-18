@echo off
echo Importing BIOS settings...
SCEWIN_64.exe /o /s "%ProgramData%\warris\BIOSSettings.txt" /q /hb /ni
echo BIOS settings imported successfully.
