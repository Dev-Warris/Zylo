param([string]$BiosFile)

# List of parameters to disable (matches your requirements)
$paramsToDisable = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum",
    "SMT Control", "AMD Cool'N'Quiet", "Fast Boot",
    "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support",
    "Ipv6 PXE Support", "IPv6 HTTP Support", "PSS Support",
    "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation",
    "SR-IOV Support", "BME DMA Mitigation", "Opcache Control"
)

$content = Get-Content $BiosFile -Raw

# Improved regex pattern that handles your BIOS format exactly
$pattern = '(?sm)(Setup Question\s*=\s*(?<name>.*?)\r?\n.*?Token\s*=\s*.*?\r?\n.*?Offset\s*=\s*.*?\r?\n.*?Width\s*=\s*.*?\r?\n(?:BIOS Default\s*=\s*.*?\r?\n)?Options\s*=\s*.*?)(\r?\n\s*)(\*?\[[0-9]+\][^\r\n]*)'

$content = [regex]::Replace($content, $pattern, {
    param($match)
    $paramName = $match.Groups['name'].Value.Trim()
    
    if ($paramsToDisable -contains $paramName) {
        $newOptions = $match.Groups[1].Value -replace '\*\[[0-9]+\]', ''
        return $newOptions + $match.Groups[2].Value + "*[00]Disabled"
    }
    
    return $match.Value
})

# Write back with proper AMI formatting
[System.IO.File]::WriteAllText($BiosFile, $content, [System.Text.Encoding]::ASCII)

# Count changes
$disabledCount = ($content | Select-String "\*\[00\]Disabled" -AllMatches).Matches.Count
Write-Output "$disabledCount parameters disabled successfully"
