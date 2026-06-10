param(
  [string]$BaseUrl = "https://maxontorres.github.io",
  [int]$Width = 1200,
  [int]$Height = 630
)

$ErrorActionPreference = "Stop"

# Resolve paths from the script location so it can be run from any working
# directory and still write images into the site repo.
$Root = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $Root "images\og"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# System.Drawing is built in on Windows PowerShell. Some newer PowerShell
# installs expose it through System.Drawing.Common instead.
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

  # Reads a single meta tag where the identifying attribute appears before the
  # content attribute, which matches the format used in this static site.
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

  # Pulls canonical URLs and other link hrefs from the document head.
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

  # Prefer JSON-LD images/contentUrl values when an existing og:image already
  # points at a generated OG image. This avoids using an old generated card as
  # the source image for the next generated card.
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

  # Turn the canonical URL path into a stable filename, using "home" for the
  # root page.
  $path = $Canonical -replace "^https?://[^/]+", ""
  $path = $path.Trim("/")
  if ([string]::IsNullOrWhiteSpace($path)) {
    $path = "home"
  }

  $slug = $path -replace "[^A-Za-z0-9]+", "-"
  $slug = $slug.Trim("-").ToLowerInvariant()
  return "$slug.jpg"
}

function Resolve-LocalImage {
  param(
    [string]$ImageUrl,
    [string]$PageDirectory
  )

  if ([string]::IsNullOrWhiteSpace($ImageUrl)) {
    return $null
  }

  # Accept site-absolute URLs, root-relative paths, and page-relative paths.
  # Fully remote images (e.g. ImageKit) are downloaded to a temp file because
  # System.Drawing only reads local files.
  $localPath = $ImageUrl
  if ($localPath.StartsWith($BaseUrl)) {
    $localPath = $localPath.Substring($BaseUrl.Length)
  }

  if ($localPath -match "^https?://") {
    $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName() + ".img")
    try {
      Invoke-WebRequest -Uri $localPath -OutFile $tempFile -UseBasicParsing
      return $tempFile
    } catch {
      return $null
    }
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

  # Build lines word by word, measuring each candidate with the actual drawing
  # font so the final rendered text stays inside the card.
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

  # Add an ellipsis when the available line count is exhausted.
  if ($truncated -and $lines.Count -eq $MaxLines -and $words.Count -gt 0) {
    $last = $lines[$lines.Count - 1]
    if ($Graphics.MeasureString("$last ...", $Font).Width -le $MaxWidth) {
      $lines[$lines.Count - 1] = "$last ..."
    }
  }

  return $lines.ToArray()
}

function Draw-TrackedText {
  param(
    [System.Drawing.Graphics]$Graphics,
    [string]$Text,
    [System.Drawing.Font]$Font,
    [System.Drawing.Brush]$Brush,
    [int]$X,
    [int]$Y,
    [double]$TrackingEm
  )

  # Draws text character-by-character with extra horizontal advance, since
  # System.Drawing has no native letter-spacing/tracking support.
  $tracking = $Font.Size * $TrackingEm
  $cursorX = [double]$X
  foreach ($ch in $Text.ToCharArray()) {
    $glyph = [string]$ch
    $Graphics.DrawString($glyph, $Font, $Brush, [single]$cursorX, $Y)
    $cursorX += $Graphics.MeasureString($glyph, $Font).Width + $tracking
  }
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
    # Draw at high quality because these images are shared as large social
    # preview cards.
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.Clear([System.Drawing.Color]::FromArgb(7, 7, 7))

    if ($SourceImage) {
      # Cover-crop the source image so it fills the 1200x630 canvas without
      # distortion, then center it.
      $source = [System.Drawing.Image]::FromFile($SourceImage)
      $scale = [Math]::Max($Width / $source.Width, $Height / $source.Height)
      $drawWidth = [int][Math]::Ceiling($source.Width * $scale)
      $drawHeight = [int][Math]::Ceiling($source.Height * $scale)
      $drawX = [int](($Width - $drawWidth) / 2)
      $drawY = [int](($Height - $drawHeight) / 2)
      $graphics.DrawImage($source, $drawX, $drawY, $drawWidth, $drawHeight)
    }

    # Darken the whole image for consistent depth, then layer a stronger
    # left-side panel so the title stays legible regardless of what the
    # source photo looks like behind it.
    $fullOverlay = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(110, 7, 7, 7))
    $graphics.FillRectangle($fullOverlay, 0, 0, $Width, $Height)
    $fullOverlay.Dispose()

    $textPanelRect = New-Object System.Drawing.Rectangle 0, 0, ([int]($Width * 0.65)), $Height
    $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
      $textPanelRect,
      [System.Drawing.Color]::FromArgb(225, 7, 7, 7),
      [System.Drawing.Color]::FromArgb(0, 7, 7, 7),
      0
    )
    $graphics.FillRectangle($gradient, $textPanelRect)
    $gradient.Dispose()

    # Extra footer contrast for the display URL.
    $bottomBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(140, 7, 7, 7))
    $graphics.FillRectangle($bottomBrush, 0, ($Height - 122), $Width, 122)
    $bottomBrush.Dispose()

    $paper = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(243, 235, 221))
    $mutedPaper = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(199, 243, 235, 221))
    $accent = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(225, 50, 27))

    $brandFont = New-Object System.Drawing.Font "Segoe UI", 22, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $titleFont = New-Object System.Drawing.Font "Impact", 72, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    $urlFont = New-Object System.Drawing.Font "Segoe UI", 24, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)

    $graphics.FillRectangle($accent, 78, 86, 78, 6)
    Draw-TrackedText -Graphics $graphics -Text "MAXON TORRES" -Font $brandFont -Brush $accent -X 78 -Y 110 -TrackingEm 0.16

    # Render the title as the main text on the generated OG image, in
    # uppercase to match the site's display heading style.
    Draw-WrappedText -Graphics $graphics -Text $Title.ToUpperInvariant() -Font $titleFont -Brush $paper -X 74 -Y 208 -MaxWidth 800 -LineHeight 76 -MaxLines 3 | Out-Null

    $displayUrl = $Canonical -replace "^https?://", ""
    $graphics.DrawString($displayUrl, $urlFont, $mutedPaper, 78, ($Height - 72))

    $brandFont.Dispose()
    $titleFont.Dispose()
    $urlFont.Dispose()
    $paper.Dispose()
    $mutedPaper.Dispose()
    $accent.Dispose()

    # Save as a quality-compressed JPEG. Social platforms re-encode previews
    # anyway, so a lossless PNG just wastes bandwidth (1MB+ vs ~100KB).
    $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]75)
    $bitmap.Save($OutputImage, $jpegCodec, $encoderParams)
    $encoderParams.Dispose()
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

  # Only updates existing meta tags. Missing tags are handled by Upsert-AfterMeta
  # so the new tags can be placed next to related metadata.
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

  # If the target tag already exists, replace it in place. Otherwise insert it
  # after a nearby anchor meta tag to keep the head organized.
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

# Generate one OG image per page and keep each page's social meta tags in sync
# with the generated image path.
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

  # Choose the best available source image for the page. Generated OG images are
  # ignored as inputs so repeated runs do not compound text overlays.
  $sourceUrl = Get-MetaContent -Html $html -Attribute "property" -Name "og:image"
  if ($sourceUrl -match "/images/og/") {
    $sourceUrl = Get-StructuredImage -Html $html
  }
  if (-not $sourceUrl) {
    $sourceUrl = Get-FirstPageImage -Html $html
  }
  $sourceImage = Resolve-LocalImage -ImageUrl $sourceUrl -PageDirectory $page.DirectoryName
  if (-not $sourceImage -and $canonical -match "/notes/?$") {
    $sourceImage = Resolve-LocalImage -ImageUrl "https://ik.imagekit.io/maxontorres/maxon-torres-motorcycle-rider.png?tr=w-1200,q-80" -PageDirectory $page.DirectoryName
  }
  if (-not $sourceImage) {
    $sourceImage = Resolve-LocalImage -ImageUrl "https://ik.imagekit.io/maxontorres/maxon-torres-black-polo-portrait.png?tr=w-1200,q-80" -PageDirectory $page.DirectoryName
  }

  # The generated image filename follows the canonical URL, not the local folder
  # name, so hosted URLs and local files remain predictable.
  $filename = ConvertTo-OgFilename -Canonical $canonical
  $outputPath = Join-Path $OutDir $filename
  $displayTitle = $title -replace "\s+\|\s+Maxon Torres$", ""
  New-OgImage -SourceImage $sourceImage -OutputImage $outputPath -Title $displayTitle -Description $description -Canonical $canonical

  if ($sourceImage -and $sourceImage.StartsWith([System.IO.Path]::GetTempPath())) {
    Remove-Item -LiteralPath $sourceImage -Force -ErrorAction SilentlyContinue
  }

  # Point Open Graph and Twitter cards at the freshly generated image.
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
