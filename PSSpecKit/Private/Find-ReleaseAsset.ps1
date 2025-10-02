function Find-ReleaseAsset {
    param(
        $Release,
        [string]$Agent,
        [string]$Shell
    )
    $pattern = "spec-kit-template-{0}-{1}-v" -f ($Agent -replace '[^a-zA-Z0-9_-]',''), $Shell
    # Try find asset containing pattern
    foreach ($asset in $Release.assets) {
        if ($asset.name -like "*{0}*.zip" -f $pattern) {
            return $asset
        }
    }
    return $null
}
