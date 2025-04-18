@echo off
setlocal enabledelayedexpansion
cls
title BIOS Optimizer - Version Expert FR

:: Vérification admin silencieuse
fsutil dirty query %SystemDrive% >nul 2>&1 || (
    echo [!] Relance en mode administrateur...
    timeout /t 1 >nul
    powershell Start-Process -FilePath "%~0" -Verb RunAs -ArgumentList "--elevated"
    exit /b
)

:: Configuration
set "WORKDIR=%ProgramData%\BIOS_Toolkit"
set "SCEWIN=%WORKDIR%\SCEWIN_64.exe"
set "BIOS_FILE=%WORKDIR%\BIOSSettings.txt"

:: Initialisation
if not exist "%WORKDIR%" mkdir "%WORKDIR%"
cd /d "%WORKDIR%"

echo #############################################
echo #  BIOS Optimizer - Version Expert         #
echo #############################################

:: Phase 1: Export BIOS
echo [1/3] Export des paramètres actuels...
"%SCEWIN%" /o "%BIOS_FILE%" /q /b
if not exist "%BIOS_FILE%" (
    echo [!] Echec de l'export, tentative alternative...
    "%SCEWIN%" /o /s "%BIOS_FILE%" /q
)

:: Phase 2: Optimisation en PowerShell intégré
echo [2/3] Application des optimisations...
powershell -nologo -noprofile -command ^
    $content = [System.IO.File]::ReadAllText('%BIOS_FILE%', [System.Text.Encoding]::ASCII); ^
    $params = 'IOMMU', 'Spread Spectrum', 'SB Clock Spread Spectrum', 'SMT Control', 'AMD Cool''N''Quiet', 'Fast Boot'; ^
    foreach ($param in $params) { ^
        $content = $content -replace "(Setup Question\s*=\s*$param.*?Options\s*=\s*.*?\r?\n\s*)\*?\[[0-9]+\]", "`$1*[00]Disabled"; ^
    } ^
    [System.IO.File]::WriteAllText('%BIOS_FILE%', $content, [System.Text.Encoding]::ASCII); ^
    $count = ($content | Select-String "\*\[00\]Disabled" -AllMatches).Matches.Count; ^
    Write-Host "$count parametres desactives avec succes"

:: Phase 3: Import avec méthode garantie
echo [3/3] Mise à jour du BIOS...
start "" /wait "%SCEWIN%" /i "%BIOS_FILE%" /q /b /f
if %ERRORLEVEL% neq 0 (
    echo [!] Utilisation de la méthode manuelle...
    echo Lancez manuellement cette commande:
    echo "%SCEWIN%" /i "%BIOS_FILE%" /f
    pause
    exit /b
)

echo #############################################
echo #  OPERATION REUSSIE - Redemarrage requis  #
echo #############################################
echo Fichier modifie: %BIOS_FILE%
timeout /t 5 >nul
