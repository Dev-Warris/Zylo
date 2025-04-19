# Liste des paramètres à rechercher
$settingsToFind = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum", "SMT Control", 
    "AMD Cool'N'Quiet", "Fast Boot", "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support", "Ipv6 PXE Support", 
    "IPv6 HTTP Support", "PSS Support", "AB Clock Gating", "PCIB Clock Run", 
    "Enable Hibernation", "SR-IOV Support", "BME DMA Mitigation", "Opcache Control"
)

# Lire le fichier BIOS et le traiter
$biosFilePath = "C:\Users\%username%\Desktop\SCEWIN_64\SCEWIN_64\BIOSSettings.txt"
$tempFilePath = "C:\Users\%username%\Desktop\SCEWIN_64\SCEWIN_64\BIOSSettings_modified.txt"

# Ouvrir le fichier pour le lire
$content = Get-Content $biosFilePath

# Variable pour garder le contenu modifié
$modifiedContent = @()

# Variable pour capturer une section de paramètres
$currentSection = @()

# Fonction pour traiter la section du BIOS
function ProcessSection($section) {
    # Vérifier si la question de setup correspond à l'une des cibles
    foreach ($setting in $settingsToFind) {
        if ($section -match "Setup Question\s*=\s*$setting") {
            # Trouver la ligne Options et ajouter l'astérisque à l'option Disabled
            $section = $section -replace '(\[00\]Disabled)', '*[00]Disabled'
            return $section
        }
    }
    return $section
}

# Parcourir chaque ligne du fichier
foreach ($line in $content) {
    # Si la ligne contient un Setup Question, débuter une nouvelle section
    if ($line -match 'Setup Question\s*=\s*(.+)') {
        # Ajouter la section précédente modifiée si elle existe
        if ($currentSection.Count -gt 0) {
            $modifiedContent += ProcessSection -section ($currentSection -join "`r`n")
        }
        # Réinitialiser la section en cours
        $currentSection = @($line)
    } else {
        # Ajouter la ligne à la section en cours
        $currentSection += $line
    }
}

# Ajouter la dernière section
if ($currentSection.Count -gt 0) {
    $modifiedContent += ProcessSection -section ($currentSection -join "`r`n")
}

# Sauvegarder le contenu modifié dans un nouveau fichier
$modifiedContent | Set-Content $tempFilePath

# Afficher un message de succès
Write-Host "Modification terminée. Le fichier modifié est : $tempFilePath"
