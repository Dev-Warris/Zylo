param(
    [string]$ExportPath,  # Chemin vers l'export BIOS (par exemple Results.txt)
    [string]$OutputPath   # Chemin de sortie pour BIOSSettings.txt
)

# Liste des paramètres à forcer sur ENABLE ou spécifiques
$enabledParams = @{
    "Special Display Features" = "PowerXpress"   # Exemple, forcer PowerXpress
    "PX Dynamic Mode" = "dGPU Power Down"         # Exemple, forcer dGPU Power Down
    "Primary Video Adaptor" = "Ext Graphics (PEG)"  # Exemple, forcer Ext Graphics
    "Discrete GPU's Audio" = "Keep ROM Strap Setting" # Exemple, forcer Keep ROM Strap Setting
}

# Liste complète des paramètres à modifier
$targetParams = @(
    "Special Display Features", 
    "PX Dynamic Mode", 
    "Primary Video Adaptor",
    "Discrete GPU's Audio"  # Autres paramètres que tu souhaites filtrer
)

# Lire le fichier exporté
$lines = Get-Content $ExportPath

# Initialisation
$output = @()
$currentBlock = @()
$currentQuestion = ""
$currentToken = ""
$found = $false

foreach ($line in $lines) {
    if ($line -match "^Setup Question\s*=\s*(.+)$") {
        # On a trouvé un nouveau paramètre (Setup Question)
        if ($found -and $targetParams -contains $currentQuestion) {
            # Si on a trouvé un paramètre qu'on veut, on l'ajoute au bloc de sortie
            $output += $currentBlock
            $output += ""  # Ligne vide pour séparer les blocs
        }

        # Nouveau paramètre
        $currentQuestion = $matches[1].Trim()
        $currentBlock = @($line)  # On commence un nouveau bloc
        $found = $false
    } elseif ($line -match "^Token\s*=\s*(\S+)") {
        # On capture le token
        $currentToken = $matches[1].Trim()
        $currentBlock += $line
    } elseif ($line -match "^Options\s*=(.*)$") {
        # Capture des options et traitement
        $options = $matches[1].Trim()

        # Vérifier si le paramètre fait partie de ceux que l'on souhaite modifier
        if ($targetParams -contains $currentQuestion) {
            $found = $true
            # Trouver l'option que l'on souhaite forcer
            $desiredOption = $enabledParams[$currentQuestion]
            if ($options -like "*$desiredOption*") {
                # Si l'option correspond, on marque l'option comme activée
                $options = $options -replace "^\s*\*\[.*\]", "*[" + $desiredOption + "]"
            }
        }

        # Ajouter la ligne des options modifiées
        $currentBlock += "Options = $options"
    } elseif ($line -match "^\s*\*\[\d+\](.+)$") {
        # Capture la ligne avec une option actuelle sélectionnée
        $currentBlock += $line
    }
}

# Ajouter le dernier bloc s'il existe
if ($found -and $targetParams -contains $currentQuestion) {
    $output += $currentBlock
}

# Écrire dans le fichier de sortie
$output | Set-Content $OutputPath -Encoding ascii

Write-Host "BIOSSettings.txt généré avec succès à : $OutputPath"
