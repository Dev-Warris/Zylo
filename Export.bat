@echo off
echo Exporting BIOS settings...
SCEWIN_64.exe /O /s "%ProgramData%\warris\Results.txt" /hb /q
echo BIOS settings exported successfully.
