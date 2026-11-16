# SEO and machine-readable identity audit

Reviewed on 2026-11-16. Changes are local to this checkout; no deployment was performed.

## Findings and changes

- Both live language pages already had HTTPS self-canonical URLs, reciprocal
  `uk`/`en` alternate links, and a Ukrainian `x-default`. Preserved these.
- Added the person's full name and handle to each localized document title.
  Descriptions remain the existing natural-language summaries. HTML, social,
  and structured page metadata use the same translated values.
- Added one JSON-LD graph per page: `Person`, `WebSite`, `ProfilePage`, and a
  `CreativeWork` describing Корені. Both languages share stable person, website,
  and project IDs; each language has its own page ID and canonical URL.
- The person includes both name spellings, the undead404 alias, the current
  job title, the existing portrait, and GitHub, Threads, and X identity links
  already visible on the page. No inferred birth dates, credentials, awards,
  contact details, or other unsupported personal claims were added.
- Корені has an explicit creator statement in the visible biography, supporting
  its `CreativeWork.creator` relationship. Other project links and contributions
  were not automatically converted into authored works. The profile uses
  `mentions`, rather than treating this externally hosted project as a page
  belonging to the personal website.
- Added Open Graph title, description, canonical URL, site name, locales, and
  image metadata, plus equivalent Twitter summary-card tags and the existing
  X account as creator. Reused the actual 640×640 JPEG portrait with translated
  image alternative text. A square summary card suits this asset without cropping
  it into a landscape banner or inventing promotional imagery.
- Kept root sitemap entries limited to the two canonical profile pages. Removed
  unsupported weekly update hints and blanket maximum priority. Post URLs now
  use Jekyll's `absolute_url` filter consistently with page URLs. Existing
  post-date handling remains; no build-time freshness dates were introduced.
- Preserved `robots.txt`: all crawlers may access the site, and it references
  the root sitemap plus the two separately hosted project sitemaps.
- Excluded repository agent instructions, this audit, and validation scripts
  from the published output.
- Did not add `llms.txt`: two language pages with ordinary HTML navigation and
  direct project links already provide a short, usable entry point. A second
  manually maintained index would add little navigational value here.
- No visible biography text, sections, styles, or layout were changed by this task.
  Existing uncommitted content and design work was preserved.

## Validation

```sh
bundle exec jekyll build
bundle exec ruby scripts/validate_metadata.rb
```

The validator parses the built HTML, JSON-LD, and sitemap XML. It checks graph
references, shared cross-language identities, supported visible identity links,
metadata agreement, canonical URLs, reciprocal hreflang, preview asset existence,
navigation targets, crawler directives, and build exclusions.

For the audit, the emitted graph was also checked against the official
[Schema.org JSON-LD vocabulary](https://schema.org/version/latest/schemaorg-current-https.jsonld),
including class inheritance, property domains, and value ranges:

```sh
curl -L --fail --max-time 30 -o /tmp/schemaorg-current-https.jsonld https://schema.org/version/latest/schemaorg-current-https.jsonld
bundle exec ruby scripts/validate_metadata.rb _site /tmp/schemaorg-current-https.jsonld
```

Both language pages passed. The image was visually inspected and its actual
dimensions were verified. Live HTTP checks returned 200 for `/`, `/en/`,
`/robots.txt`, `/sitemap.xml`, the portrait, and both project sitemaps. All three
live sitemaps parsed as XML. Neither live profile response included a blocking
`X-Robots-Tag` header. The root live sitemap listed the same two canonical URLs.

References: [Person](https://schema.org/Person),
[WebSite](https://schema.org/WebSite), [ProfilePage](https://schema.org/ProfilePage),
[CreativeWork](https://schema.org/CreativeWork), and the
[Open Graph protocol](https://ogp.me/).

## Remaining limitations

- Live pages still reflect the previously deployed version. After publishing,
  recheck both URLs with the Schema.org validator and the target platforms'
  preview tools. No hosted validation of the unpublished changes was claimed.
- Vocabulary and consistency validation does not guarantee Google rich-result
  eligibility, indexing, AI citations, ranking improvements, or social preview
  rendering. No Search Console indexing or search-performance data was available
  in this repository audit.
- Social services may cache an earlier preview and may render the same square
  image differently. No new image file or design change is required here.
- The two linked project sites are separate publishing units. Their sitemap
  endpoints were verified, but their individual pages and metadata were not
  comprehensively audited or changed in this task.
- Current employment and project descriptions will need normal editorial
  maintenance in both languages. No fabricated publication or modification dates
  were added to profile structured data.
- Jekyll builds successfully with an existing warning about pagination lacking
  an `index.html` template, plus an optional Faraday retry dependency notice.
  Neither prevents this static two-page site from building.
