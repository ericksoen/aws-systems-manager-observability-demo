<powershell>
$content = @'
${user_data}
'@
$path = Join-Path $env:SystemRoot  "Temp\functions.ps1"
Set-Content -Path $path -Value $content
</powershell>