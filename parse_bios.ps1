param(
    [string]$ExportPath,
    [string]$OutputPath
)

# Liste des paramètres à forcer sur ENABLE ou avec une option spécifique
$enabledParams = @{
    "Channel Interleaving" = "Enabled"
    "Bank Interleaving" = "Enabled"
    "PPC Adjustment" = "PState 0"
    "PCI-X Latency Timer" = "32 PCI Bus Clocks"
}

# Liste des paramètres ciblés
$targetParams = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum", "SMT Control",
    "AMD Cool'N'Quiet", "Fast Boot", "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support", "Ipv6 PXE Support", "IPv6 HTTP Support",
    "PSS Support", "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation", "SR-IOV Support",
    "BME DMA Mitigation", "Opcache Control", "PCI-X Latency Timer", "Above 4G memory/Crypto Currency mining",
    "Special Display Features", "PM L1 SS", "Clock Power Management(CLKREQ#", "Channel Interleaving",
    "Bank Interleaving", "SATA GPIO", "Aggressive Link PM Capability", "Core C6 State", "PPC Adjustment"
)

# Header obligatoire
$header = @()
// Date du jour
$now = Get-Date -Format "MM/dd/yy 'at' HH:mm:ss"
$header += "// Script File Name : BIOSSettings.txt"
$header += "// Created on $now"
$header += "// Copyright (c)2018 American Megatrends, Inc."
$header += "// AMISCE Utility. Ver 5.03.1115"
$header += ""
$header += "HIICrc32= 16BBDC39"
$header += ""

# Lecture du fichier exporté
$lines = Get-Content $ExportPath
$output = @()
$currentBlock = @()
$foundName = ""
$inBlock = $false

foreach ($line in $lines) {
    if ($line -match "^Setup Question\s*=\s*(.+)$") {
        if ($inBlock -and $targetParams -contains $foundName) {
            $output += $currentBlock + ""
        }
        $foundName = $matches[1].Trim()
        $currentBlock = @($line)
        $inBlock = $true
    } elseif ($inBlock -and $line -match "^\s*Options\s*=") {
        $processedOptions = @()
        $desired = $enabledParams[$foundName]

        for ($i = 0; $i -lt 10; $i++) {
            if ($lines[$lines.IndexOf($line) + $i] -match "^\s*(\*?)\[(\w+)\](.+)$") {
                $isSelected = $matches[1]
                $hex = $matches[2]
                $option = $matches[3].Trim()

                if ($desired -and $option -like "*$desired*") {
                    $processedOptions += "         *[$hex]$option"
                } elseif (-not $desired -and $option -like "*Disabled*") {
                    $processedOptions += "         *[$hex]$option"
                } else {
                    $processedOptions += "         [$hex]$option"
                }
            } else {
                break
            }
        }

        $currentBlock += $line
        $currentBlock += $processedOptions
        $inBlock = $false

    } elseif ($inBlock -and $line -match "^(Token|Offset|Width)\s*=") {
        $currentBlock += $line
    }
}

if ($inBlock -and $targetParams -contains $foundName) {
    $output += $currentBlock + ""
}

# Sauvegarde du fichier proprement
$final = $header + $output
$final | Set-Content -Encoding ascii -Path $OutputPath
