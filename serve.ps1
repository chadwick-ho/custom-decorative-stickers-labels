$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Port = if ($args.Count -gt 0) { [int]$args[0] } else { 4173 }
$Prefix = "http://localhost:$Port/"
$Listener = [System.Net.HttpListener]::new()
$Listener.Prefixes.Add($Prefix)
$Listener.Start()
Write-Host "Serving $Root at $Prefix"

function Get-ContentType($Path) {
  switch ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
    ".html" { "text/html; charset=utf-8" }
    ".css" { "text/css; charset=utf-8" }
    ".js" { "application/javascript; charset=utf-8" }
    ".png" { "image/png" }
    ".jpg" { "image/jpeg" }
    ".jpeg" { "image/jpeg" }
    ".svg" { "image/svg+xml" }
    default { "application/octet-stream" }
  }
}

while ($Listener.IsListening) {
  $Context = $Listener.GetContext()
  try {
    $Path = [Uri]::UnescapeDataString($Context.Request.Url.AbsolutePath.TrimStart("/"))
    if ([string]::IsNullOrWhiteSpace($Path)) { $Path = "index.html" }
    $LocalPath = Join-Path $Root $Path
    if (Test-Path -LiteralPath $LocalPath -PathType Container) {
      $LocalPath = Join-Path $LocalPath "index.html"
    }
    if (-not (Test-Path -LiteralPath $LocalPath -PathType Leaf)) {
      $Context.Response.StatusCode = 404
      $bytes = [Text.Encoding]::UTF8.GetBytes("Not found")
    } else {
      $Context.Response.StatusCode = 200
      $Context.Response.ContentType = Get-ContentType $LocalPath
      $bytes = [IO.File]::ReadAllBytes($LocalPath)
    }
    $Context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } finally {
    $Context.Response.OutputStream.Close()
  }
}
