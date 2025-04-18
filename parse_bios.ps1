param(
    [string]$ExportPath,
    [string]$OutputPath
)

# Liste des paramètres à forcer sur ENABLE ou spécifiques
$enabledParams = @{
    "Channel Interleaving" = "Enabled"
    "Bank Interleaving" = "Enabled"
    "PPC Adjustment" = "PState 0"
    "PCI-X Latency Timer" = "32 PCI Bus Clocks"
}

# Liste complète des paramètres à garder
$targetParams = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum", "SMT Control",
    "AMD Cool'N'Quiet", "Fast Boot", "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support", "Ipv6 PXE Support", "IPv6 HTTP Support",
    "PSS Support", "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation", "SR-IOV Support",
    "BME DMA Mitigation", "Opcache Control", "PCI-X Latency Timer", "Above 4G memory/Crypto Currency mining",
    "Special Display Features", "PM L1 SS", "Clock Power Management(CLKREQ#", "Channel Interleaving",
    "Bank Interleaving", "SATA GPIO", "Aggressive Link PM Capability", "Core C6 State", "PPC Adjustment"
)

# Lire le fichier d'export
$lines = Get-Content $ExportPath
$inBlock = $false
$currentBlock = @()
$foundName = ""
$startSection = $true  # Flag pour le début du fichier

# Créer une liste pour les résultats à conserver
$output = @()

foreach ($line in $lines) {
    # Garde le début du fichier intact
    if ($startSection) {
        $output += $line
        if ($line -match "AMISCE Utility") {
            $startSection = $false  # À partir de ce moment, on commence à traiter les paramètres
        }
    } else {
        # Si on trouve un paramètre dans la liste targetParams
        if ($line -match "^Setup Question\s*=\s*(.+)$") {
            $foundName = $matches[1].Trim()
            $currentBlock = @($line)
            $inBlock = $true
        }
        # Si on est dans un bloc, on va ajouter les lignes
        elseif ($inBlock -and $line -match "^\s*\*?\[\w+\](.+?)$") {
            $option = $matches[1].Trim()
            $desired = $enabledParams[$foundName]
            if ($targetParams -contains $foundName) {
                if ($desired -and $option -like "*$desired*") {
                    $line = $line -replace "^\s*\*?", "         *"
                } elseif (-not $desired -and $option -like "*Disabled*") {
                    $line = $line -replace "^\s*\*?", "         *"
                } else {
                    $line = $line -replace "^\s*\*", "         "
                }
                $currentBlock += $line
            }
        }
        # Si on atteint la fin d'un bloc, on ajoute le bloc si le paramètre est dans la liste
        elseif ($inBlock -and $line -match "^Setup Question") {
            $inBlock = $false
            if ($targetParams -contains $foundName) {
                $output += $currentBlock
                $output += ""  # Ajouter une ligne vide entre les blocs
            }
            $currentBlock = @($line)
            $foundName = $line
            $inBlock = $true
        }
    }
}

# Écrire le fichier de sortie avec les résultats filtrés
$output | Set-Content $OutputPath -Encoding ascii
