param([string]$FichierBIOS)

$paramsADesactiver = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum",
    "SMT Control", "AMD Cool'N'Quiet", "Fast Boot",
    "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support",
    "Ipv6 PXE Support", "IPv6 HTTP Support", "PSS Support",
    "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation",
    "SR-IOV Support", "BME DMA Mitigation", "Opcache Control"
)

$contenu = Get-Content $FichierBIOS -Raw

$pattern = '(?sm)(Setup Question\s*=\s*(?<nom>.*?)\r?\n(?!.*Token.*Offset.*Width)(Options\s*=\s*.*?\r?\n\s*)(\*?\[[0-9]+\][^\r\n]*)'

$contenu = [regex]::Replace($contenu, $pattern, {
    param($match)
    if ($paramsADesactiver -contains $match.Groups['nom'].Value.Trim()) {
        $lignesOptions = $match.Groups[2].Value + $match.Groups[3].Value
        $lignesOptions = $lignesOptions -replace '\*\[[0-9]+\]', ''
        return $match.Groups[1].Value + $lignesOptions.Trim() + "`r`n         *[00]Disabled"
    }
    return $match.Value
})

[IO.File]::WriteAllText($FichierBIOS, $contenu, [Text.Encoding]::ASCII)

$nbModifs = ($contenu | Select-String "\*\[00\]Disabled" -AllMatches).Matches.Count
Write-Output "$nbModifs paramètres ont été désactivés"
