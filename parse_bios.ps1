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

# Liste complète des paramètres à modifier
$targetParams = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum", "SMT Control",
    "AMD Cool'N'Quiet", "Fast Boot", "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support", "Ipv6 PXE Support", "IPv6 HTTP Support",
    "PSS Support", "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation", "SR-IOV Support",
    "BME DMA Mitigation", "Opcache Control", "PCI-X Latency Timer", "Above 4G memory/Crypto Currency mining",
    "Special Display Features", "PM L1 SS", "Clock Power Management(CLKREQ#", "Channel Interleaving",
    "Bank Interleaving", "SATA GPIO", "Aggressive Link PM Capability", "Core C6 State", "PPC Adjustment"
)

# Read export file and prepare output
$output = @()
$lines = Get-Content $ExportPath
$inBlock = $false
$currentBlock = @()
$foundName = ""

foreach ($line in $lines) {
    if ($line -match "^Setup Question\s*=\s*(.+)$") {
        if ($inBlock -and $targetParams -contains $foundName) {
            $output += $currentBlock
            $output += "" # ligne vide
        }
        $foundName = $matches[1].Trim()
        $currentBlock = @($line)
        $inBlock = $true
    } elseif ($inBlock -and $line -match "^Setup Question") {
        $inBlock = $false
        if ($targetParams -contains $foundName) {
            $output += $currentBlock
            $output += "" # ligne vide
        }
        $currentBlock = @($line)
        $foundName = $line
        $inBlock = $true
    } elseif ($inBlock) {
        if ($line -match "^\s*\*?\[\w+\](.+?)$") {
            $option = $matches[1].Trim()
            $desired = $enabledParams[$foundName]
            if ($desired -and $option -like "*$desired*") {
                $line = $line -replace "^\s*\*?", "         *"
            } elseif (-not $desired -and $option -like "*Disabled*") {
                $line = $line -replace "^\s*\*?", "         *"
            } else {
                $line = $line -replace "^\s*\*", "         "
            }
        }
        $currentBlock += $line
    }
}

# Dernier bloc
if ($inBlock -and $targetParams -contains $foundName) {
    $output += $currentBlock
}

# Écriture
$output | Set-Content $OutputPath -Encoding ascii
