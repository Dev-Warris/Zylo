param(
    [string]$InputFile = "BIOS_Raw.txt",
    [string]$OutputFile = "BIOS_Optimized.txt"
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

$content = Get-Content $InputFile
$output = @()
$currentBlock = @()
$disableCurrent = $false

foreach ($line in $content) {
    if ($line -match "^Setup Question\s*=\s*(.+)") {
        $paramName = $matches[1].Trim()
        $disableCurrent = $disableParams -contains $paramName
    }

    if ($disableCurrent -and $line -match "Options\s*=\s*(.+)") {
        $line = $line -replace "\*\[[0-9]+\]", "*[00]"
        $line = $line -replace "\[00\]", "*[00]"
    }

    $output += $line
}

$output | Out-File $OutputFile -Encoding ASCII
