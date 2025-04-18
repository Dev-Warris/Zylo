param(
    [string]$InputFile = "BIOSSettings.txt"
)

# Complete list of parameters to disable
$paramsToDisable = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum",
    "SMT Control", "AMD Cool'N'Quiet", "Fast Boot",
    "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support",
    "Ipv6 PXE Support", "IPv6 HTTP Support", "PSS Support",
    "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation",
    "SR-IOV Support", "BME DMA Mitigation", "Opcache Control"
)

$content = Get-Content $InputFile -Raw

# Enhanced regex pattern for complete parameter blocks
$pattern = '(?s)(Setup Question\s*=\s*(?<name>.*?)\r?\n.*?Token\s*=\s*.*?\r?\n.*?Offset\s*=\s*.*?\r?\n.*?Width\s*=\s*.*?\r?\n.*?BIOS Default\s*=\s*.*?\r?\n.*?Options\s*=\s*(?<options>.*?)(\r?\n\s*\*?\[[0-9]+\].*?)*)'

$content = [regex]::Replace($content, $pattern, {
    param($match)
    $paramName = $match.Groups['name'].Value.Trim()
    $optionsBlock = $match.Groups[0].Value
    
    if ($paramsToDisable -contains $paramName) {
        # Remove all existing selections
        $optionsBlock = $optionsBlock -replace '\*\[[0-9]+\]', ''
        # Force selection to [00]Disabled
        $optionsBlock = $optionsBlock -replace '(\r?\n\s*)(\[00\])', "`$1*`$2"
        # Remove other selections
        $optionsBlock = $optionsBlock -replace '(\r?\n\s*)\*\[', "`$1 ["
    }
    
    return $optionsBlock
})

# Rewrite file with proper AMI formatting
[System.IO.File]::WriteAllText($InputFile, $content, [System.Text.Encoding]::ASCII)

# Final verification
$disabledCount = (Select-String -Path $InputFile -Pattern "\*\[00\]" -AllMatches).Matches.Count
Write-Output "$disabledCount parameters have been disabled"
