param(
    [string]$InputFile = "BIOSSettings.txt"
)

$disableParams = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum",
    "SMT Control", "AMD Cool'N'Quiet", "Fast Boot",
    "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support",
    "Ipv6 PXE Support", "IPv6 HTTP Support", "PSS Support",
    "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation",
    "SR-IOV Support", "BME DMA Mitigation", "Opcache Control"
)

$content = Get-Content $InputFile -Raw
$newContent = [System.Text.StringBuilder]::new()

$pattern = '(?sm)(Setup Question\s*=\s*(?<name>.*?)\r?\n.*?Options\s*=\s*(?<options>.*?)(\r?\n\s*\*?\[[0-9]+\].*?)*)'

$content = [regex]::Replace($content, $pattern, {
    param($match)
    $paramName = $match.Groups['name'].Value.Trim()
    $optionsBlock = $match.Groups[0].Value
    
    if ($disableParams -contains $paramName) {
        # Supprimer toutes les sélections existantes
        $optionsBlock = $optionsBlock -replace '\*\[[0-9]+\]', ''
        # Ajouter *[00]Disabled en dernière position
        $optionsBlock = $optionsBlock -replace '(\r?\n\s*)(\[[0-9]+\])', "`$1*`$2"
        $optionsBlock = $optionsBlock -replace '(\r?\n\s*)\*\[00\]', "`$1*[00]"
    }
    
    return $optionsBlock
})

# Écrire le résultat dans le même fichier
[System.IO.File]::WriteAllText($InputFile, $content, [System.Text.Encoding]::ASCII)
