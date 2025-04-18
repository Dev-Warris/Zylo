param(
    [string]$InputFile = "BIOS_Raw.txt",
    [string]$OutputFile = "BIOS_Optimized.txt"
)

# Liste des paramètres à désactiver
$disableParams = @(
    "IOMMU",
    "Spread Spectrum",
    "SB Clock Spread Spectrum",
    "SMT Control",
    "AMD Cool'N'Quiet",
    "Fast Boot",
    "Global C-state Control",
    "Chipset Power Saving Features",
    "Remote Display Feature",
    "PS2 Devices Support",
    "Ipv6 PXE Support",
    "IPv6 HTTP Support",
    "PSS Support",
    "AB Clock Gating",
    "PCIB Clock Run",
    "Enable Hibernation",
    "SR-IOV Support",
    "BME DMA Mitigation",
    "Opcache Control"
)

$content = Get-Content $InputFile -Raw
$pattern = '(?sm)(Setup Question\s*=\s*(?<name>.*?)\r?\n.*?Options\s*=\s*.*?\*\[)(?<value>\d+)'

$content = [regex]::Replace($content, $pattern, {
    param($match)
    $paramName = $match.Groups['name'].Value.Trim()
    
    if ($disableParams -contains $paramName) {
        return $match.Groups[1].Value + "00" + $match.Groups[3].Value.Substring(2)
    }
    return $match.Value
})

$content | Out-File $OutputFile -Encoding ASCII
