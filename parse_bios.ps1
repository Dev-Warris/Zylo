param(
    [string]$ExportPath,
    [string]$OutputPath
)

# Charger le fichier d'export
$exportContent = Get-Content -Path $ExportPath

# Créer un tableau vide pour stocker les paramètres modifiés
$updatedSettings = @()

# Définir les paramètres à rechercher et leurs nouvelles valeurs
$settingsToModify = @{
    "Core Performance Boost" = "Disabled"
    "Global C-state Control" = "Disabled"
    "Power Supply Idle Control" = "Typical Current Idle"
    "GFX Voltage" = "0"
}

# Parcourir chaque ligne de l'export
foreach ($line in $exportContent) {
    foreach ($param in $settingsToModify.Keys) {
        if ($line -like "*$param*") {
            # Trouver le Token de la ligne correspondante
            $tokenLine = $exportContent[$exportContent.IndexOf($line) + 1]
            $token = ($tokenLine -split "=")[1].Trim()

            # Ajouter la ligne modifiée
            $updatedSettings += "Setup Question = $param"
            $updatedSettings += "Token = $token"
            $updatedSettings += "BIOS Default = <$($settingsToModify[$param])>"
            $updatedSettings += "Value = <$($settingsToModify[$param])>"
            $updatedSettings += ""
        }
    }
}

# Sauvegarder les paramètres modifiés dans le fichier de sortie
$updatedSettings | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "BIOS settings have been successfully updated."
