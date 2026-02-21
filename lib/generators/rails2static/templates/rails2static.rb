Rails2static.configure do |config|
  # Output directory for the generated static site
  # config.output_dir = "_site"

  # Starting paths for the crawl
  # config.entry_paths = ["/"]

  # Host header sent with requests
  # config.host = "www.example.com"

  # URL style: true  -> /about/index.html (works with most static hosts)
  #            false -> /about.html
  # config.trailing_slash = true

  # Regex patterns for paths to skip
  # config.exclude_patterns = [%r{/admin}]

  # Collect and write CSS, JS, images, and fonts
  # config.include_assets = true

  # Safety limit on pages crawled
  # config.max_pages = 10_000
end
