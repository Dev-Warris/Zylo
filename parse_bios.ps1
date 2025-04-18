param($ExportPath = "BIOS_Backup.txt")

$paramsToDisable = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum", 
    "SMT Control", "AMD Cool'N'Quiet", "Fast Boot",
    "Global C-state Control", "Chipset Power Saving Features"
)

$content = Get-Content $ExportPath
$output = @()
$currentBlock = @()
$disableCurrent = $false

foreach ($line in $content) {
    if ($line -match "^Setup Question\s*=\s*(.+)") {
        $paramName = $matches[1].Trim()
        $disableCurrent = $paramsToDisable -contains $paramName
    }

    if ($disableCurrent -and $line -match "Options\s*=\s*(.+)") {
        $line = $line -replace "\*\[00\]", " [00]" -replace "\[\d+\]", "*[00]"
    }

    $output += $line
}

$output | Out-File "BIOS_Optimized.txt" -Encoding ASCII
