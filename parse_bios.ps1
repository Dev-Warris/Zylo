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

$pattern = '(?sm)(Setup Question\s*=\s*(?<name>.*?)\r?\n.*?Options\s*=\s*)(?<options>.*?)(\r?\n\s*\*?\[00\]Disabled)?'

$content = [regex]::Replace($content, $pattern, {
    param($match)
    $paramName = $match.Groups['name'].Value.Trim()
    
    if ($disableParams -contains $paramName) {
        $cleanOptions = $match.Groups['options'].Value -replace '\*\[[0-9]+\]', ''
        return $match.Groups[1].Value + $cleanOptions + "`r`n         *[00]Disabled"
    }
    return $match.Value
})

$content | Out-File $InputFile -Encoding ASCII
