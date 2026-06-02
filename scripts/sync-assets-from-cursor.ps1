# Copy built web assets from Cursor Projects into Flutter assets/images.
$src = "C:\Users\coolb\Cursor Projects\build"
$dst = Join-Path (Split-Path $PSScriptRoot -Parent) "assets\images"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
$files = @(
  "DEITECIrc.webp", "DEITECIrc-192.webp", "crew-icon.png",
  "Gemini_Generated_Image_enm22aenm22aenm2.png", "DeteaIcon.png",
  "hub-icon.png", "hub-logo.png", "reddit-logo.png", "x-logo.png",
  "ai-avatar.png", "apple-avatar.png", "banana-avatar.png",
  "broccoli-avatar.png", "carrot-avatar.png", "pineapple-avatar.png",
  "strawberry-avatar.png"
)
foreach ($f in $files) {
  $p = Join-Path $src $f
  if (Test-Path $p) { Copy-Item -Force $p $dst; Write-Host "OK $f" }
  else { Write-Host "Skip (missing): $f" }
}
Write-Host "Done -> $dst"
