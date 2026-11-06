# undead404.github.io

My personal website. Jekyll, the Hacker theme, Markdown, and GitHub Pages.

## Structure

- `index.md` — the Ukrainian homepage at `/`.
- `en/index.md` — the English version at `/en/`.
- `_data/i18n/{uk,en}.yml` — translated layout labels and metadata.
- `_layouts/default.html` — the custom Hacker-based field-terminal layout and branching circuit illustration.
- `_config.yml` — Jekyll settings and theme selection.
- `assets/css/style.scss` — the Hacker theme import, custom design, and responsive layouts.
- `assets/style/style.scss` — legacy theme entry point.
- `assets/img/` — original photos and project screenshots.
- `sitemap.xml` — sitemap template.

The homepage has its own entry point instead of depending on GitHub Pages interpreting this README as a website. Repository documentation is excluded from the published site.

## Local development

This project uses Ruby 3.3.13 through mise. macOS's bundled Ruby 2.6 is too old for the dependency set. With mise installed, run from this directory:

```sh
mise install
mise exec -- bundle install
mise exec -- bundle exec jekyll serve
```

Open the local address printed by Jekyll. To build without starting a server:

```sh
mise exec -- bundle exec jekyll build
```

The `github-pages` gem uses GitHub Pages' dependency set. `Gemfile.lock` records the resolved versions for local development. Update it deliberately with `mise exec -- bundle update github-pages`. Using `mise exec --` explicitly selects the project's Ruby, even if your shell still resolves plain `ruby` or `bundle` to macOS's system installation.

See [GitHub's local Jekyll guide](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/testing-your-github-pages-site-locally-with-jekyll).

## Publishing

Keep using the repository's existing GitHub Pages publishing source. No additional hosting service, JavaScript framework, or deployment workflow is required.

## Languages

Ukrainian is the default language. The header links to English at `/en/` and back to Ukrainian at `/`. Update both Markdown files together when content changes, and both translation files when interface text changes. Keep explicit section IDs identical across translations so navigation links remain stable. Both pages share the layout, styles, images, and reciprocal language metadata.
