param (
    [string]$filePath
)

if (!(Test-Path $filePath)) {
    Write-Host "[X] BIOS file not found." -ForegroundColor Red
    exit 1
}

$content = Get-Content -Raw -Encoding ASCII -Path $filePath

$parametersToDisable = @(
    'IOMMU',
    'Spread Spectrum',
    'SB Clock Spread Spectrum',
    'SMT Control',
    "AMD Cool'N'Quiet",
    'Fast Boot',
    'Global C-state Control',
    'Chipset Power Saving Features',
    'Remote Display Feature',
    'PS2 Devices Support',
    'Ipv6 PXE Support',
    'IPv6 HTTP Support',
    'PSS Support',
    'AB Clock Gating',
    'PCIB Clock Run',
    'SR-IOV Support',
    'BME DMA Mitigation',
    'Opcache Control'
)

foreach ($param in $parametersToDisable) {
    $pattern = "($param.*?Options\s*=.*?\r?\n\s*)\*?\[[0-9]+\]"
    $replacement = '$1*[00]Disabled'
    $content = [regex]::Replace($content, $pattern, $replacement)
}

Set-Content -Encoding ASCII -Path $filePath -Value $content

# Count how many parameters were successfully disabled
$matchCount = ([regex]::Matches($content, "\*\[00\]Disabled")).Count
Write-Host "$matchCount BIOS parameters modified successfully." -ForegroundColor Green
