# Rails2static

Generate a deployable static site from a server-rendered Rails app. Add the gem, run a rake task, and get a `_site/` directory with HTML, CSS, JS, and images ready to deploy anywhere.

Rails2static uses [Rack::Test](https://github.com/rack/rack-test) to call your Rails app directly — no running server needed. It crawls your app through the full middleware stack, rewrites links for static hosting, and collects all referenced assets.

## Installation

Add to your Gemfile:

```ruby
gem "rails2static"
```

Then `bundle install`.

Generate the initializer:

```sh
rails generate rails2static:install
```

## Usage

```sh
rake rails2static
# or
rake static:generate
```

This will:

1. BFS-crawl your app starting from `/`
2. Rewrite internal links for static hosting
3. Collect all referenced CSS, JS, images, and fonts
4. Copy `public/` directory files (favicon, robots.txt, etc.)
5. Write everything to `_site/`

Preview the result locally:

```sh
rake static:preview
```

This starts a local server at http://localhost:8000 serving your generated site.

## Configuration

The install generator creates `config/initializers/rails2static.rb` with all options commented out. Uncomment and adjust as needed:

```ruby
Rails2static.configure do |config|
  config.output_dir = "_site"              # Output directory (default: "_site")
  config.entry_paths = ["/"]               # Starting paths for the crawl (default: ["/"])
  config.host = "www.example.com"          # Host header sent with requests (default: "www.example.com")
  config.trailing_slash = true             # /about -> /about/index.html (default: true)
                                           # false  -> /about -> /about.html
  config.exclude_patterns = [%r{/admin}]   # Regex patterns to skip (default: [])
  config.include_assets = true             # Collect CSS/JS/images (default: true)
  config.max_pages = 10_000                # Safety limit on pages crawled (default: 10,000)
end
```

## How it works

- **Crawler** — BFS from entry paths using `Rack::Test::Session`. Normalizes paths, follows redirects internally, detects cycles, skips external links, warns on 404s.
- **Link Extractor** — Parses HTML with Nokogiri for `<a>`, `<link>`, `<script>`, `<img>`, `srcset`, `<video>`, and `<audio>` references.
- **Link Rewriter** — Rewrites `<a href>` values so links work on static hosts. Skips external links, anchors, mailto/tel, and paths with file extensions.
- **Asset Collector** — Fetches all asset URLs found in HTML via Rack::Test. Parses CSS for `url()` and `@import` references and fetches those recursively.
- **Writer** — Writes HTML as `path/index.html` (trailing slash mode) or `path.html`. Non-HTML content keeps its original path. Binary content uses `binwrite`.

## Demo

The `demo/` directory contains a fully working Rails blog app that showcases rails2static. It uses SQLite with a pre-seeded database so you can try it immediately:

```sh
cd demo
bundle install
rake rails2static     # generates _site/
rake static:preview   # serves it at http://localhost:8000
```

The demo app includes:

- Posts with categories (HABTM), an about page, and a shared layout
- Admin scaffolds at `/admin` (excluded from static output)
- 4 seed posts, 3 categories, and an about page

## License

MIT
