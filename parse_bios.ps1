param(
    [string]$FichierBIOS = "BIOSSettings.txt"
)

# Liste complète des paramètres à désactiver
$paramsDesactiver = @(
    "IOMMU", "Spread Spectrum", "SB Clock Spread Spectrum",
    "SMT Control", "AMD Cool'N'Quiet", "Fast Boot",
    "Global C-state Control", "Chipset Power Saving Features",
    "Remote Display Feature", "PS2 Devices Support",
    "Ipv6 PXE Support", "IPv6 HTTP Support", "PSS Support",
    "AB Clock Gating", "PCIB Clock Run", "Enable Hibernation",
    "SR-IOV Support", "BME DMA Mitigation", "Opcache Control"
)

$contenu = Get-Content $FichierBIOS -Raw

# Pattern amélioré pour la compatibilité AMI
$pattern = '(?sm)(Setup Question\s*=\s*(?<nom>.*?)\r?\n.*?Options\s*=\s*)(?<options>.*?)(\r?\n\s*)(\*?\[[0-9]+\].*?)*'

$contenu = [regex]::Replace($contenu, $pattern, {
    param($match)
    $nomParam = $match.Groups['nom'].Value.Trim()
    
    if ($paramsDesactiver -contains $nomParam) {
        $nouvellesOptions = $match.Groups['options'].Value -replace '\*\[[0-9]+\]', ''
        return $match.Groups[1].Value + $nouvellesOptions + $match.Groups[3].Value + "*[00]Disabled"
    }
    
    return $match.Value
})

# Réécriture du fichier avec formatage correct
[System.IO.File]::WriteAllText($FichierBIOS, $contenu, [System.Text.Encoding]::ASCII)

# Comptage des modifications
$nbModifs = ($contenu | Select-String "\*\[00\]Disabled" -AllMatches).Matches.Count
Write-Output "$nbModifs parametres desactives avec succes"
