function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$Retries = 3
    )
    $attempt = 0
    while ($true) {
        try {
            return & $ScriptBlock
        } catch {
            $attempt++
            if ($attempt -ge $Retries) { throw }
            $delay = [math]::Pow(2, $attempt)
            Write-Warn "Attempt $attempt failed. Retrying in ${delay}s..."
            Start-Sleep -Seconds $delay
        }
    }
}
