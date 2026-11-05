# undead404.github.io

My personal website. Jekyll, the Hacker theme, Markdown, and GitHub Pages.

## Structure

- `index.md` — the homepage, with current projects and a nostalgic archive of past work.
- `_layouts/default.html` — the original Hacker-based page layout.
- `_config.yml` — Jekyll settings and theme selection.
- `assets/style/style.scss` — the existing theme import.
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
