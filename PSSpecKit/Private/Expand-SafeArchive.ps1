function Expand-SafeArchive {
    param([string]$ZipPath, [string]$TargetPath, [switch]$Force)
    # Extract into a temporary extraction directory located next to the zip when possible.
    # This keeps the downloaded zip in the parent work directory and allows us to remove only the extraction temp.
    $zipParent = Split-Path -Path $ZipPath -Parent
    if (-not $zipParent) { $zipParent = [System.IO.Path]::GetTempPath() }
    $tempExtract = Join-Path -Path $zipParent -ChildPath ([System.Guid]::NewGuid().ToString())
    New-Item -Path $tempExtract -ItemType Directory | Out-Null
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $tempExtract)
        # Move files from temp to target
        Get-ChildItem -Path $tempExtract -Recurse | ForEach-Object {
            $rel = $_.FullName.Substring($tempExtract.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
            $dest = Join-Path $TargetPath $rel
            if ($_.PSIsContainer) {
                if (-not (Test-Path $dest)) { New-Item -Path $dest -ItemType Directory | Out-Null }
            } else {
                $destDir = Split-Path -Path $dest -Parent
                if (-not (Test-Path $destDir)) { New-Item -Path $destDir -ItemType Directory | Out-Null }
                if ((Test-Path $dest) -and (-not $Force)) {
                    Write-Warn "Skipping existing file: $dest"
                } else {
                    Move-Item -Path $_.FullName -Destination $dest -Force:$true
                }
            }
        }
        return $true
    } catch {
        Write-Err "Extraction failed: $_"
        return $false
    } finally {
        # Remove only the extraction temp directory. Do NOT remove the zip or its parent work directory.
        if (Test-Path $tempExtract) { Remove-Item -Path $tempExtract -Recurse -Force }
    }
}
