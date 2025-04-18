param (
    [string]$ExportPath,
    [string]$OutputPath
)

$targetSettings = @{
    "Memory Try It?" = "Disabled"
    "HPET" = "Disabled"
    "Intel Virtualization Technology" = "Disabled"
    "SVM Mode" = "Disabled"
    "Cool'n'Quiet" = "Disabled"
    "C1E Support" = "Disabled"
    "Global C-state Control" = "Disabled"
    "CPB" = "Enabled"
    "PSS Support" = "Enabled"
    "NX Mode" = "Disabled"
    "PCI Latency Timer" = "32"
}

$lines = Get-Content $ExportPath
$output = @()
$inBlock = $false
$currentBlock = @()

foreach ($line in $lines) {
    if ($line -match "^Setup Question\s*=\s*(.+)$") {
        $question = $Matches[1].Trim()
        $inBlock = $true
        $currentBlock = @($line)
    } elseif ($inBlock -and $line -match "^(Token|Offset|Width|Options|\\*\\[|\\[)") {
        $currentBlock += $line
    } elseif ($inBlock -and $line -eq "") {
        $inBlock = $false
        if ($targetSettings.ContainsKey($question)) {
            $desired = $targetSettings[$question]
            $modifiedBlock = $currentBlock | ForEach-Object {
                if ($_ -match "^\s*[\*]?\[(\d+)\](.+)$") {
                    $val = $Matches[2].Trim()
                    if ($val -eq $desired) {
                        return "*[$Matches[1]]$val"
                    } else {
                        return "[$Matches[1]]$val"
                    }
                } else {
                    return $_
                }
            }
            $output += $modifiedBlock + ""
        }
    }
}

# Include header lines from original file
$header = $lines | Select-Object -First 5
$header + $output | Set-Content -Encoding ASCII $OutputPath
