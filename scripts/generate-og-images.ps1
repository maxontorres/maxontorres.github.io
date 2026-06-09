param(
  [string]$BaseUrl = "https://maxontorres.github.io",
  [int]$Width = 1200,
  [int]$Height = 630
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $Root "images\og"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

try {
  Add-Type -AssemblyName System.Drawing
} catch {
  Add-Type -AssemblyName System.Drawing.Common
}

function Get-MetaContent {
  param(
    [string]$Html,
    [string]$Attribute,
    [string]$Name
  )

  $pattern = "<meta\s+[^>]*$Attribute=`"$([regex]::Escape($Name))`"[^>]*content=`"([^`"]+)`"[^>]*>"
  $match = [regex]::Match($Html, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($match.Success) {
    return [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
  }

  return $null
}

function Get-LinkHref {
  param(
    [string]$Html,
    [string]$Rel
  )

  $pattern = "<link\s+[^>]*rel=`"$([regex]::Escape($Rel))`"[^>]*href=`"([^`"]+)`"[^>]*>"
  $match = [regex]::Match($Html, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($match.Success) {
    return [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
  }

  return $null
}

function Get-Title {
  param([string]$Html)

  $match = [regex]::Match($Html, "<title>(.*?)</title>", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($match.Success) {
    return [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
  }

  return "Maxon Torres"
}

function Get-StructuredImage {
  param([string]$Html)

  $matches = [regex]::Matches($Html, '"(?:image|contentUrl)"\s*:\s*"([^"]+)"')
  foreach ($match in $matches) {
    $url = [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
    if ($url -notmatch "/images/og/") {
      return $url
    }
  }

  return $null
}

function Get-FirstPageImage {
  param([string]$Html)

  $match = [regex]::Match($Html, '<img\s+[^>]*src="([^"]+)"', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ($match.Success) {
    return [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
  }

  return $null
}

function ConvertTo-OgFilename {
  param([string]$Canonical)

  $path = $Canonical -replace "^https?://[^/]+", ""
  $path = $path.Trim("/")
  if ([string]::IsNullOrWhiteSpace($path)) {
    $path = "home"
  }

  $slug = $path -replace "[^A-Za-z0-9]+", "-"
  $slug = $slug.Trim("-").ToLowerInvariant()
  return "$slug.png"
}

function Resolve-LocalImage {
  param(
    [string]$ImageUrl,
    [string]$PageDirectory
  )

  if ([string]::IsNullOrWhiteSpace($ImageUrl)) {
    return $null
  }

  $localPath = $ImageUrl
  if ($localPath.StartsWith($BaseUrl)) {
    $localPath = $localPath.Substring($BaseUrl.Length)
  }

  if ($localPath -match "^https?://") {
    return $null
  }

  if ($localPath.StartsWith("/")) {
    $localPath = $localPath.Substring(1)
    $fullPath = Join-Path $Root ($localPath -replace "/", "\")
    if (Test-Path $fullPath) {
      return $fullPath
    }
    return $null
  }

  $fullPath = Join-Path $Root ($localPath -replace "/", "\")
  if (Test-Path $fullPath) {
    return $fullPath
  }

  if ($PageDirectory) {
    $relativePath = Join-Path $PageDirectory ($localPath -replace "/", "\")
    if (Test-Path $relativePath) {
      return $relativePath
    }
  }

  return $null
}

function Get-WrappedLines {
  param(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [System.Drawing.Font]$Font,
    [int]$MaxWidth,
    [int]$MaxLines
  )

  $words = $Text -split "\s+"
  $lines = New-Object System.Collections.Generic.List[string]
  $line = ""
  $truncated = $false

  foreach ($word in $words) {
    $candidate = if ($line) { "$line $word" } else { $word }
    if ($Graphics.MeasureString($candidate, $Font).Width -le $MaxWidth) {
      $line = $candidate
      continue
    }

    if ($line) {
      $lines.Add($line)
      $line = $word
    } else {
      $lines.Add($word)
    }

    if ($lines.Count -ge $MaxLines) {
      $truncated = $true
      break
    }
  }

  if ($line -and $lines.Count -lt $MaxLines) {
    $lines.Add($line)
  }

  if ($truncated -and $lines.Count -eq $MaxLines -and $words.Count -gt 0) {
    $last = $lines[$lines.Count - 1]
    if ($Graphics.MeasureString("$last ...", $Font).Width -le $MaxWidth) {
      $lines[$lines.Count - 1] = "$last ..."
    }
  }

  return $lines.ToArray()
}

function Draw-WrappedText {
  param(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [System.Drawing.Font]$Font,
    [System.Drawing.Brush]$Brush,
    [int]$X,
    [int]$Y,
    [int]$MaxWidth,
    [int]$LineHeight,
    [int]$MaxLines
  )

  $lines = @(Get-WrappedLines -Graphics $Graphics -Text $Text -Font $Font -MaxWidth $MaxWidth -MaxLines $MaxLines)
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $Graphics.DrawString($lines[$i], $Font, $Brush, $X, ($Y + ($i * $LineHeight)))
  }

  return $Y + ($lines.Count * $LineHeight)
}

function New-OgImage {
  param(
    [string]$SourceImage,
    [string]$OutputImage,
    [string]$Title,
    [string]$Description,
    [string]$Canonical
  )

  $bitmap = New-Object System.Drawing.Bitmap $Width, $Height
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $source = $null

  try {
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::FromArgb(20, 22, 22))

    if ($SourceImage) {
      $source = [System.Drawing.Image]::FromFile($SourceImage)
      $scale = [Math]::Max($Width / $source.Width, $Height / $source.Height)
      $drawWidth = [int][Math]::Ceiling($source.Width * $scale)
      $drawHeight = [int][Math]::Ceiling($source.Height * $scale)
      $drawX = [int](($Width - $drawWidth) / 2)
      $drawY = [int](($Height - $drawHeight) / 2)
      $graphics.DrawImage($source, $drawX, $drawY, $drawWidth, $drawHeight)
    }

    $overlayRect = New-Object System.Drawing.Rectangle 0, 0, $Width, $Height
    $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      $overlayRect,
      [System.Drawing.Color]::FromArgb(235, 13, 15, 15),
      [System.Drawing.Color]::FromArgb(30, 13, 15, 15),
      0
    )
    $graphics.FillRectangle($gradient, $overlayRect)
    $gradient.Dispose()

    $bottomBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(115, 13, 15, 15))
    $graphics.FillRectangle($bottomBrush, 0, ($Height - 122), $Width, 122)
    $bottomBrush.Dispose()

    $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(248, 246, 239))
    $muted = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(205, 199, 187))
    $accent = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(230, 185, 98))

    $brandFont = New-Object System.Drawing.Font "Segoe UI", 26, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $titleFont = New-Object System.Drawing.Font "Segoe UI", 78, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $descFont = New-Object System.Drawing.Font "Segoe UI", 31, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
    $urlFont = New-Object System.Drawing.Font "Segoe UI", 24, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)

    $graphics.FillRectangle($accent, 78, 82, 78, 5)
    $graphics.DrawString("Maxon Torres", $brandFont, $muted, 78, 108)

    $nextY = Draw-WrappedText -Graphics $graphics -Text $Title -Font $titleFont -Brush $white -X 74 -Y 208 -MaxWidth 780 -LineHeight 88 -MaxLines 3
    $nextY += 24
    Draw-WrappedText -Graphics $graphics -Text $Description -Font $descFont -Brush $muted -X 78 -Y $nextY -MaxWidth 720 -LineHeight 42 -MaxLines 2 | Out-Null

    $displayUrl = $Canonical -replace "^https?://", ""
    $graphics.DrawString($displayUrl, $urlFont, $muted, 78, ($Height - 72))

    $brandFont.Dispose()
    $titleFont.Dispose()
    $descFont.Dispose()
    $urlFont.Dispose()
    $white.Dispose()
    $muted.Dispose()
    $accent.Dispose()

    $bitmap.Save($OutputImage, [System.Drawing.Imaging.ImageFormat]::Png)
  } finally {
    if ($source) { $source.Dispose() }
    $graphics.Dispose()
    $bitmap.Dispose()
  }
}

function Set-MetaContent {
  param(
    [string]$Html,
    [string]$Attribute,
    [string]$Name,
    [string]$Value
  )

  $escapedName = [regex]::Escape($Name)
  $pattern = "(<meta\s+[^>]*$Attribute=`"$escapedName`"[^>]*content=`")([^`"]+)(`"[^>]*>)"
  if ([regex]::IsMatch($Html, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
    return [regex]::Replace($Html, $pattern, "`${1}$Value`${3}", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
  }

  return $Html
}

function Upsert-AfterMeta {
  param(
    [string]$Html,
    [string]$AnchorAttribute,
    [string]$AnchorName,
    [string]$Tag
  )

  $attr = if ($Tag -match 'property="([^"]+)"') { "property" } else { "name" }
  $name = if ($Tag -match '(?:property|name)="([^"]+)"') { $matches[1] } else { $null }
  if ($name) {
    $existingPattern = "<meta\s+[^>]*$attr=`"$([regex]::Escape($name))`"[^>]*>"
    if ([regex]::IsMatch($Html, $existingPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
      return [regex]::Replace($Html, $existingPattern, $Tag, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
  }

  $anchorPattern = "(<meta\s+[^>]*$AnchorAttribute=`"$([regex]::Escape($AnchorName))`"[^>]*>\r?\n)"
  return [regex]::Replace($Html, $anchorPattern, "`${1}  $Tag`r`n", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
}

$pages = Get-ChildItem -Path $Root -Recurse -Filter "index.html" |
  Where-Object { $_.FullName -notmatch "\\\.git\\" }

foreach ($page in $pages) {
  $html = Get-Content -LiteralPath $page.FullName -Raw
  $canonical = Get-LinkHref -Html $html -Rel "canonical"
  if (-not $canonical) {
    continue
  }

  $title = Get-MetaContent -Html $html -Attribute "property" -Name "og:title"
  if (-not $title) { $title = Get-Title -Html $html }

  $description = Get-MetaContent -Html $html -Attribute "property" -Name "og:description"
  if (-not $description) { $description = Get-MetaContent -Html $html -Attribute "name" -Name "description" }
  if (-not $description) { $description = "Personal photos, notes, and articles by Maxon Torres." }

  $sourceUrl = Get-MetaContent -Html $html -Attribute "property" -Name "og:image"
  if ($sourceUrl -match "/images/og/") {
    $sourceUrl = Get-StructuredImage -Html $html
  }
  if (-not $sourceUrl) {
    $sourceUrl = Get-FirstPageImage -Html $html
  }
  $sourceImage = Resolve-LocalImage -ImageUrl $sourceUrl -PageDirectory $page.DirectoryName
  if (-not $sourceImage -and $canonical -match "/notes/?$") {
    $sourceImage = Join-Path $Root "images\maxon-torres-motorcycle-rider.png"
  }
  if (-not $sourceImage) {
    $sourceImage = Join-Path $Root "images\maxon-torres-black-polo-portrait.png"
  }

  $filename = ConvertTo-OgFilename -Canonical $canonical
  $outputPath = Join-Path $OutDir $filename
  $displayTitle = $title -replace "\s+\|\s+Maxon Torres$", ""
  New-OgImage -SourceImage $sourceImage -OutputImage $outputPath -Title $displayTitle -Description $description -Canonical $canonical

  $ogUrl = "$BaseUrl/images/og/$filename"
  $html = Set-MetaContent -Html $html -Attribute "property" -Name "og:image" -Value $ogUrl
  $html = Upsert-AfterMeta -Html $html -AnchorAttribute "property" -AnchorName "og:image" -Tag '<meta property="og:image:width" content="1200" />'
  $html = Upsert-AfterMeta -Html $html -AnchorAttribute "property" -AnchorName "og:image:width" -Tag '<meta property="og:image:height" content="630" />'
  $html = Upsert-AfterMeta -Html $html -AnchorAttribute "name" -AnchorName "twitter:card" -Tag "<meta name=`"twitter:title`" content=`"$title`" />"
  $html = Upsert-AfterMeta -Html $html -AnchorAttribute "name" -AnchorName "twitter:title" -Tag "<meta name=`"twitter:description`" content=`"$description`" />"
  $html = Upsert-AfterMeta -Html $html -AnchorAttribute "name" -AnchorName "twitter:description" -Tag "<meta name=`"twitter:image`" content=`"$ogUrl`" />"

  Set-Content -LiteralPath $page.FullName -Value $html -NoNewline
  Write-Host "Generated images/og/$filename"
}
