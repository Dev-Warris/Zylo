@echo off
echo Exporting BIOS settings...
SCEWIN_64.exe /O /E "%ProgramData%\warris\Results.txt"
echo BIOS settings exported successfully.
