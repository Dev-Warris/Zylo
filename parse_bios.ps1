@echo off
setlocal enabledelayedexpansion
cls
title BIOS Optimizer - Version Finale FR

:: Vérification admin ultra-fiable
whoami /groups | find "S-1-16-12288" > nul || (
    echo [!] Relance en admin...
    timeout /t 1 >nul
    powershell Start-Process -FilePath "%~0" -Verb RunAs
    exit /b
)

set "DOSSIER=%ProgramData%\BIOS_Optimizer"
set "SCEWIN=%DOSSIER%\SCEWIN_64.exe"
set "FICHIER_BIOS=%DOSSIER%\BIOSSettings.txt"

mkdir "%DOSSIER%" 2>nul
cd /d "%DOSSIER%"

echo #############################################
echo #  BIOS Optimizer - Version Professionnelle #
echo #############################################

:: Phase 1: Export simple
echo [1/3] Export BIOS en cours...
"%SCEWIN%" /o "%FICHIER_BIOS%" /q
if not exist "%FICHIER_BIOS%" (
    echo [!] Echec export, tentative 2...
    "%SCEWIN%" /o "%FICHIER_BIOS%" /q /b
)

:: Phase 2: Optimisation PowerShell
echo [2/3] Application des optimisations...
powershell -nop -c ^
    $c=gc '%FICHIER_BIOS%' -Raw; ^
    $p='IOMMU','Spread Spectrum','SB Clock Spread Spectrum','SMT Control'; ^
    $p+='AMD Cool''N''Quiet','Fast Boot','Global C-state Control'; ^
    foreach($i in $p){ ^
        $c=$c -replace "($i.*?Options\s*=.*?\r?\n\s*)\*?\[[0-9]+\]","`$1*[00]Disabled"; ^
    } ^
    sc '%FICHIER_BIOS%' $c -Enc ASCII; ^
    (sls '\*\[00\]Disabled' -input $c -All).Matches.Count

:: Phase 3: Import ULTRA compatible
echo [3/3] Import final...
if exist "%FICHIER_BIOS%" (
    echo Lancement de SCEWIN en mode manuel...
    start "" /wait "%SCEWIN%" /i "%FICHIER_BIOS%" /q
    if %ERRORLEVEL% neq 0 (
        echo [!] Methode forcee...
        start "" /wait "%SCEWIN%" /i "%FICHIER_BIOS%" /f
    )
)

echo #############################################
echo #  TERMINE! Redemarrez pour appliquer.     #
echo #  Fichier: %FICHIER_BIOS%                #
echo #############################################
pause
