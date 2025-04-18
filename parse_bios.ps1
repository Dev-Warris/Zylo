param(
    [string]$ExportPath,
    [string]$OutputPath
)

# Lire le fichier exporté
$exportContent = Get-Content -Path $ExportPath

# Créer une liste vide pour stocker les paramètres modifiés
$updatedSettings = @()

# Définir les paramètres à rechercher et leurs nouvelles valeurs
$settingsToModify = @{
    "Spread Spectrum" = "Disabled"
    "SB Clock Spread Spectrum" = "Disabled"
    "SMT Control" = "Disabled"
    "AMD Cool'N'Quiet" = "Disabled"
    "Fast Boot" = "Disabled"
    "Global C-state Control" = "Disabled"
    "Chipset Power Saving Features" = "Disabled"
    "Remote Display Feature" = "Disabled"
    "PS2 Devices Support" = "Disabled"
    "Ipv6 PXE Support" = "Disabled"
    "IPv6 HTTP Support" = "Disabled"
    "PSS Support" = "Disabled"
    "AB Clock Gating" = "Disabled"
    "PCIB Clock Run" = "Disabled"
    "Enable Hibernation" = "Enabled"  # Hibernation = 0 (Enabled)
}

# Parcourir chaque ligne du fichier d'export pour trouver les paramètres à modifier
foreach ($line in $exportContent) {
    foreach ($param in $settingsToModify.Keys) {
        if ($line -like "*$param*") {
            # Trouver le Token correspondant
            $tokenLine = $exportContent[$exportContent.IndexOf($line) + 1]
            $token = ($tokenLine -split "=")[1].Trim()

            # Si c'est "Enable Hibernation", appliquer la règle spéciale (0 pour enable, 1 pour disable)
            if ($param -eq "Enable Hibernation") {
                $value = if ($settingsToModify[$param] -eq "Enabled") { "0" } else { "1" }
            } else {
                $value = if ($settingsToModify[$param] -eq "Disabled") { "1" } else { "0" }
            }

            # Ajouter la ligne modifiée à la liste
            $updatedSettings += "Setup Question = $param"
            $updatedSettings += "Token = $token"  # Ne pas modifier cette ligne
            $updatedSettings += "BIOS Default = 1"
            $updatedSettings += "Value = $value"
            $updatedSettings += ""
        }
    }
}

# Sauvegarder les paramètres modifiés dans le fichier de sortie
$updatedSettings | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "BIOS settings have been successfully updated."
