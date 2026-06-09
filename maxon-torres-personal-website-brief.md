# MaxonTorres.com Personal Website Design Brief

## Project Summary

Build a minimal personal website for **Maxon Torres**.

The website is not a corporate portfolio, not a SaaS landing page, and not a fake spy-themed website.

It is a **personal visual archive** with:

- epic photos from Maxon Torres' life
- short personal notes
- minimal articles
- clear SEO structure
- strong image discoverability
- AI-search-friendly identity signals

The visual inspiration comes from **1960s James Bond movie posters**, especially the bold typography, cinematic contrast, black/cream/red palette, and dramatic photo-first composition.

The design must stay minimal.

**LESS IS MORE.**  
**KISS: Keep It Simple, Stupid.**

---

## Website Title

Use only:

```txt
Maxon Torres
```

Do not rename the site to "Field Notes", "The Maxon Files", "Maxon Journal", or anything else.

The official website identity is simply:

```txt
Maxon Torres
```

---

## Main Objective

The site should make it easy for humans, search engines, and AI systems to understand:

```txt
This is the official personal website of Maxon Torres.
These photos belong to Maxon Torres.
These articles and notes were written by Maxon Torres.
This is the canonical source for public information about Maxon Torres.
```

The site should be highly SEO-friendly and AI-search-friendly without becoming visually cluttered.

---

## Content Strategy

The content will be minimal.

Primary content types:

```txt
Photos
Notes
About
```

Optional:

```txt
Articles
```

However, "Notes" is preferred over "Articles" because the writing will be personal and short.

Recommended navigation:

```txt
Maxon Torres

Photos
Notes
About
```

Avoid unnecessary sections.

Do not add:

```txt
Services
Testimonials
Case Studies
Newsletter
Resources
Categories
Tags everywhere
Complex menus
```

This is a personal archive, not a marketing website.

---

## Information Architecture

Recommended routes:

```txt
/
Homepage

/photos
Photo archive

/photos/maxon-torres-bangkok-night-2026
Individual photo page

/notes
Notes index

/notes/bangkok-after-midnight
Individual note page

/about
About Maxon Torres
```

Optional:

```txt
/contact
Contact page
```

Only add `/contact` if there is actually useful contact information.

---

## Design Mood

The mood should be:

```txt
minimal
cinematic
masculine
personal
quiet
international
slightly dangerous
1960s spy cinema inspired
```

The site should feel like:

```txt
1960s Bond poster discipline
+
modern personal archive
+
minimal editorial website
```

It should not feel like:

```txt
fan art
fake 007 site
spy cosplay
startup landing page
influencer page
corporate portfolio
travel blog template
```

---

## Visual Inspiration

Inspired by:

- 1960s James Bond movie posters
- vintage spy cinema
- old international film posters
- cinematic portraits
- editorial photo archives
- old travel photography
- warm paper textures
- bold condensed typography

Use inspiration carefully.

Do not copy copyrighted poster layouts directly.

Borrow the mood, not the literal composition.

---

## Color Palette

Use a small, strict palette.

```css
:root {
  --black: #070707;
  --paper: #F3EBDD;
  --cream: #E7D6B5;
  --red: #E1321B;
  --gold: #D4A843;
  --ink: #261D17;
  --muted: #8D806E;
  --line: rgba(38, 29, 23, 0.18);
}
```

### Usage

```txt
Black:
Dark cinematic sections, hero background, photo pages.

Warm Paper:
Main article/note background.

Cream:
Secondary soft background or image captions.

Signal Red:
Strong accent only. Use for labels, small highlights, active states.

Gold:
Secondary accent only. Use sparingly.

Ink Brown:
Main text on warm paper.

Muted:
Secondary text, dates, metadata.
```

Do not overuse red or gold.

---

## Typography

Use bold condensed typography for large display titles.

Recommended heading fonts:

```txt
Anton
League Gothic
Bebas Neue
Oswald
Archivo Black
```

Recommended body fonts:

```txt
Inter
IBM Plex Sans
Source Sans 3
Arial
```

Preferred pairing:

```txt
Display / Hero / Section Titles: Anton or League Gothic
Body / UI / Navigation: Inter or IBM Plex Sans
```

Avoid serif fonts unless specifically requested later.

The user prefers minimal sans-serif design.

---

## Homepage Concept

The homepage should be photo-first.

Suggested structure:

```txt
[Fixed minimal navigation]

Hero:
MAXON TORRES
Personal photos, notes, and moments from my life.
Large cinematic photo.

Recent Photos:
2 to 4 photo cards.

Latest Notes:
3 short note links.

About:
One short identity paragraph.

Footer:
Maxon Torres / Personal archive / year
```

The homepage should not have many sections.

A good homepage can be only:

```txt
Hero
Recent Photos
Latest Notes
About
```

That is enough.

---

## Homepage Copy

Use this:

```txt
Maxon Torres

Personal photos, notes, and moments from my life.
```

Alternative:

```txt
Maxon Torres

Photos and notes from my life.
```

Avoid overexplaining.

---

## Photo Strategy

Photos are the main content.

Each important photo should have its own page.

### Example Photo URLs

```txt
/photos/maxon-torres-bangkok-night-2026
/photos/maxon-torres-vientiane-riverside-2026
/photos/maxon-torres-black-suit-portrait
/photos/maxon-torres-airport-2026
/photos/maxon-torres-hotel-lobby
```

### Photo Filename Rules

Use descriptive filenames with the name "Maxon Torres".

Good:

```txt
maxon-torres-bangkok-night-2026.jpg
maxon-torres-vientiane-riverside-2026.jpg
maxon-torres-black-suit-portrait.jpg
maxon-torres-airport-2026.jpg
```

Bad:

```txt
IMG_4029.jpg
final-edit.jpg
photo-final.jpg
me-cool.jpg
DSC000123.jpg
```

### Photo Page Structure

Each photo page should include:

```txt
H1:
Maxon Torres in Bangkok at Night

Image:
Large photo

Caption:
Maxon Torres in Bangkok, Thailand, 2026.

Location:
Bangkok, Thailand

Date:
June 2026

Short note:
One to three sentences.
```

### Image Alt Text

Alt text should be descriptive but not bloated.

Good:

```txt
Maxon Torres standing in Bangkok at night wearing a black suit.
```

Bad:

```txt
Cool epic cinematic spy photo.
```

Good:

```txt
Maxon Torres in Vientiane, Laos near the riverside.
```

Bad:

```txt
Man in Laos.
```

The name "Maxon Torres" should appear naturally in alt text when the photo is actually of him.

---

## Notes Strategy

Notes should be short.

The writing should feel personal but not needy.

Example note structure:

```txt
Title:
Bangkok After Midnight

Date:
June 2026

Photo:
One large image

Text:
Short personal reflection.
```

Example note:

```txt
Some cities feel bigger after midnight.

Bangkok is one of them.

The heat stays.
The lights stay.
The ambition stays.
```

Keep notes minimal.

Do not add long intros, fake motivational quotes, or generic travel writing.

---

## Article / Note Page Layout

The note page should be extremely minimal.

Structure:

```txt
Navigation

Title
Date
Location

Large photo

Short text

Footer
```

Recommended text width:

```css
max-width: 680px;
```

Recommended image width:

```css
max-width: 980px;
```

Recommended body style:

```css
font-size: 18px;
line-height: 1.75;
```

---

## Design Rules

Strict rules:

```txt
1. No sidebars.
2. No author cards.
3. No newsletter boxes inside articles.
4. No floating social share buttons.
5. No fake classified stamps.
6. No spy icons.
7. No gun silhouettes.
8. No random 007 references.
9. No excessive textures.
10. No heavy gradients.
11. No cluttered cards.
12. No unnecessary animation.
13. No decorative UI noise.
14. No serif body font unless specifically requested.
15. No em dashes in copy.
```

Important: avoid em dashes. Use commas, periods, colons, or parentheses instead.

---

## SEO Requirements

The website must be SEO-friendly and AI-search-friendly.

### Core SEO Requirements

Every page should have:

```txt
Unique title tag
Meta description
Canonical URL
Open Graph tags
Twitter/X card tags
H1
Clean semantic HTML
Structured data where appropriate
Descriptive image alt text
Fast-loading optimized images
Mobile-first layout
```

### Technical Requirements

```txt
Static or server-rendered pages
No client-only rendering for content
XML sitemap
Image sitemap
robots.txt
Clean URLs
Canonical URLs
Schema.org JSON-LD
Fast Core Web Vitals
Compressed images
Responsive images with srcset where possible
Lazy loading for non-hero images
```

Avoid hiding important text inside images.

---

## AI-SEO / Entity Optimization

The site must clearly establish the entity:

```txt
Maxon Torres
```

Use consistent identity wording across the site.

Recommended identity sentence:

```txt
Maxon Torres is a software consultant and personal writer based in Southeast Asia. This website contains his personal photos, notes, and public profile information.
```

Use this or a close variation on the About page and homepage metadata.

Do not describe Maxon Torres in ten different ways across the site.

Consistency matters.

---

## Structured Data

Use JSON-LD.

### Person Schema

Add this globally or on the homepage and about page.

```json
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "Maxon Torres",
  "url": "https://www.maxontorres.com",
  "image": "https://www.maxontorres.com/images/maxon-torres-profile.jpg",
  "jobTitle": "Software Consultant",
  "sameAs": [
    "https://github.com/maxontorres",
    "https://www.instagram.com/MaxonTorres"
  ]
}
```

Update social links if needed.

### BlogPosting Schema

Use on note/article pages.

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Bangkok After Midnight",
  "image": "https://www.maxontorres.com/images/maxon-torres-bangkok-after-midnight.jpg",
  "datePublished": "2026-06-09",
  "dateModified": "2026-06-09",
  "author": {
    "@type": "Person",
    "name": "Maxon Torres",
    "url": "https://www.maxontorres.com"
  },
  "publisher": {
    "@type": "Person",
    "name": "Maxon Torres"
  }
}
```

### ImageObject Schema

Use on individual photo pages.

```json
{
  "@context": "https://schema.org",
  "@type": "ImageObject",
  "name": "Maxon Torres in Bangkok at Night",
  "contentUrl": "https://www.maxontorres.com/images/maxon-torres-bangkok-night-2026.jpg",
  "caption": "Maxon Torres in Bangkok, Thailand, 2026.",
  "creator": {
    "@type": "Person",
    "name": "Maxon Torres",
    "url": "https://www.maxontorres.com"
  }
}
```

---

## Metadata Templates

### Homepage

```txt
Title:
Maxon Torres

Meta description:
Personal photos, notes, and articles by Maxon Torres.

OG title:
Maxon Torres

OG description:
Personal photos, notes, and articles by Maxon Torres.

OG image:
https://www.maxontorres.com/images/maxon-torres-og.jpg
```

### Note Page

```txt
Title:
Bangkok After Midnight | Maxon Torres

Meta description:
A personal note by Maxon Torres about Bangkok, travel, and life in Southeast Asia.

OG title:
Bangkok After Midnight

OG description:
A personal note by Maxon Torres.

OG image:
https://www.maxontorres.com/images/maxon-torres-bangkok-after-midnight.jpg
```

### Photo Page

```txt
Title:
Maxon Torres in Bangkok at Night

Meta description:
Photo of Maxon Torres in Bangkok, Thailand.

OG title:
Maxon Torres in Bangkok at Night

OG description:
Photo from the personal website of Maxon Torres.

OG image:
https://www.maxontorres.com/images/maxon-torres-bangkok-night-2026.jpg
```

---

## Suggested Stack

Preferred:

```txt
Astro
Markdown or MDX
Static output
Image optimization
Sitemap generation
Schema components
```

Alternative:

```txt
Next.js
Static generation
MDX
next/image
Sitemap generation
```

For this website, Astro is probably better because the site is mostly static content, photos, and notes.

---

## Suggested Astro Structure

```txt
src/
  components/
    Layout.astro
    Header.astro
    Footer.astro
    PhotoCard.astro
    NoteCard.astro
    Seo.astro
    PersonSchema.astro
    ImageSchema.astro
    BlogPostingSchema.astro

  content/
    notes/
      bangkok-after-midnight.md
      life-in-motion.md

    photos/
      bangkok-night.md
      vientiane-riverside.md

  pages/
    index.astro
    photos/
      index.astro
      [slug].astro
    notes/
      index.astro
      [slug].astro
    about.astro

public/
  images/
    maxon-torres-hero.jpg
    maxon-torres-og.jpg
    maxon-torres-profile.jpg
    maxon-torres-bangkok-night-2026.jpg
```

---

## Content Model

### Photo Content Frontmatter

```yaml
---
title: "Maxon Torres in Bangkok at Night"
slug: "maxon-torres-bangkok-night-2026"
description: "Photo of Maxon Torres in Bangkok, Thailand."
image: "/images/maxon-torres-bangkok-night-2026.jpg"
alt: "Maxon Torres standing in Bangkok at night wearing a black suit."
caption: "Maxon Torres in Bangkok, Thailand, 2026."
location: "Bangkok, Thailand"
date: "2026-06-09"
---
```

Body:

```md
A short note about this moment.
```

### Note Content Frontmatter

```yaml
---
title: "Bangkok After Midnight"
slug: "bangkok-after-midnight"
description: "A personal note by Maxon Torres about Bangkok, travel, and life in Southeast Asia."
image: "/images/maxon-torres-bangkok-after-midnight.jpg"
alt: "Maxon Torres standing in Bangkok at night."
location: "Bangkok, Thailand"
date: "2026-06-09"
---
```

Body:

```md
Some cities feel bigger after midnight.

Bangkok is one of them.

The heat stays.
The lights stay.
The ambition stays.
```

---

## Homepage HTML Concept

The homepage should be based on this content hierarchy:

```html
<header>
  <a href="/">Maxon Torres</a>
  <nav>
    <a href="/photos">Photos</a>
    <a href="/notes">Notes</a>
    <a href="/about">About</a>
  </nav>
</header>

<main>
  <section>
    <p>Personal archive</p>
    <h1>Maxon Torres</h1>
    <p>Personal photos, notes, and moments from my life.</p>
    <img src="/images/maxon-torres-hero.jpg" alt="Maxon Torres in a cinematic portrait.">
  </section>

  <section>
    <h2>Recent Photos</h2>
    <!-- Photo cards -->
  </section>

  <section>
    <h2>Latest Notes</h2>
    <!-- Note links -->
  </section>

  <section>
    <h2>About</h2>
    <p>Maxon Torres is a software consultant and personal writer based in Southeast Asia. This website contains his personal photos, notes, and public profile information.</p>
  </section>
</main>

<footer>
  <p>Maxon Torres</p>
</footer>
```

---

## Homepage CSS Direction

Use this visual direction:

```css
body {
  background: #F3EBDD;
  color: #261D17;
  font-family: Inter, Arial, sans-serif;
}

.hero {
  background: #070707;
  color: #F3EBDD;
  min-height: 100vh;
}

h1, h2 {
  font-family: Anton, Impact, sans-serif;
  text-transform: uppercase;
  letter-spacing: -0.05em;
}

.accent {
  color: #E1321B;
}
```

Keep CSS simple.

---

## Accessibility Requirements

```txt
Use semantic HTML.
Use real text, not text embedded in images.
Use alt text for all meaningful images.
Use empty alt text for decorative images.
Ensure sufficient color contrast.
Ensure keyboard navigation works.
Do not rely only on color to communicate meaning.
Avoid tiny body text.
```

---

## Performance Requirements

```txt
Hero image should be optimized.
Use WebP or AVIF when possible.
Use responsive images.
Lazy load images below the fold.
Avoid unnecessary JavaScript.
Avoid animation-heavy libraries.
Avoid huge font files.
Use system fonts if speed matters.
```

---

## What Not To Build

Do not build:

```txt
A complicated CMS
A dashboard
A theme switcher
A SaaS landing page
An overanimated homepage
A 3D website
A portfolio clone
A fake classified dossier
A Bond fan page
A blog with heavy categories
```

This site should be simple.

---

## Final Design Principle

```txt
The photos are the drama.
The layout is quiet.
The SEO is explicit.
The design is minimal.
The identity is consistent.
```

If an element does not support the photo, the note, or the identity of Maxon Torres, remove it.
