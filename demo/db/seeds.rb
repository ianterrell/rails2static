# Categories
getting_started = Category.find_or_create_by!(name: "Getting Started", slug: "getting-started")
deployment = Category.find_or_create_by!(name: "Deployment", slug: "deployment")
how_it_works = Category.find_or_create_by!(name: "How It Works", slug: "how-it-works")

# Posts
post1 = Post.find_or_create_by!(slug: "getting-started-with-rails2static") do |p|
  p.title = "Getting Started with Rails2static"
  p.body = <<~BODY
    Rails2static turns your Rails app into a static site. You keep writing ERB templates, using ActiveRecord, and organizing code the Rails way — then generate plain HTML files you can deploy anywhere.

    Installation takes about a minute. Add the gem to your Gemfile:

    gem "rails2static"

    Run bundle install, then generate the initializer:

    rails generate rails2static:install

    This creates config/initializers/rails2static.rb with sensible defaults. The most important option is exclude_patterns, which lets you skip routes that shouldn't be in the static output — like admin pages or anything behind authentication.

    To generate your site, run:

    rake rails2static

    That's it. Your static site is now in the _site/ directory. You can preview it locally with:

    rake static:preview

    This starts a local server at http://localhost:8000 so you can verify everything looks right before deploying.

    The key idea is that you develop your site exactly like any Rails app. Use migrations, seeds, scaffolds, partials, helpers — whatever you'd normally use. Rails2static just adds a build step that snapshots your app into static files.
  BODY
  p.published_at = 3.days.ago
  p.published = true
end

post2 = Post.find_or_create_by!(slug: "deploying-to-cloudflare-pages") do |p|
  p.title = "Deploying to Cloudflare Pages"
  p.body = <<~BODY
    Cloudflare Pages is a great fit for rails2static sites. It supports Ruby builds natively (since Jekyll uses Ruby too), so your site builds and deploys automatically on every push.

    To set it up, connect your GitHub repository in the Cloudflare Pages dashboard, then configure the build:

    Root directory: your app's directory (e.g., "demo" if it's in a subdirectory)
    Build command: bundle install && rake rails2static
    Build output: _site

    That's all the configuration you need. Cloudflare will install your gems, run the rake task, and deploy the _site/ directory to its global CDN.

    You can add a custom domain in the Cloudflare dashboard under your Pages project settings. DNS is managed automatically if your domain is already on Cloudflare.

    Every push to your main branch triggers a new build. Cloudflare also creates preview deployments for pull requests, so you can review changes before they go live.

    Since the output is just static files on a CDN, your site loads fast everywhere in the world. There's no server to scale, no database to manage in production, and no infrastructure to worry about. Cloudflare's free tier is generous enough for most personal sites and blogs.
  BODY
  p.published_at = 1.day.ago
  p.published = true
end

post3 = Post.find_or_create_by!(slug: "how-the-crawler-works") do |p|
  p.title = "How the Crawler Works"
  p.body = <<~BODY
    Under the hood, rails2static uses a breadth-first crawler to discover and render every page in your app. Understanding how it works helps you get the most out of it.

    The process starts with entry paths — by default, just "/". The crawler fetches each entry path using Rack::Test, which calls your Rails app directly through the middleware stack without an HTTP server. This means the crawl is fast and doesn't need a running process.

    For each HTML page it fetches, the crawler parses the response with Nokogiri and extracts all internal links: a[href], link[href], script[src], img[src], and srcset attributes. These discovered URLs get added to a queue.

    The crawler continues until the queue is empty or it hits the max_pages safety limit (default: 10,000). It tracks visited URLs to avoid cycles and skips anything matching your exclude_patterns.

    After crawling, the link rewriter adjusts href attributes so they work as static files. If trailing_slash mode is enabled (the default), /about becomes /about/index.html and links point to /about/ — which most static hosts serve correctly.

    Finally, the asset collector fetches all CSS, JavaScript, images, and fonts referenced in your pages. It even parses CSS files for url() references and @import statements, fetching those recursively.

    The result is a self-contained _site/ directory with everything needed to serve your site from any static host.
  BODY
  p.published_at = 2.days.ago
  p.published = true
end

post4 = Post.find_or_create_by!(slug: "why-use-rails-for-a-static-site") do |p|
  p.title = "Why Use Rails for a Static Site?"
  p.body = <<~BODY
    There are plenty of static site generators out there — Jekyll, Hugo, Eleventy, Astro. So why would you use Rails?

    The answer is simple: you already know Rails. If you're a Rails developer, you don't need to learn a new templating language, a new content pipeline, or a new way of organizing code. ERB, partials, helpers, layouts, the asset pipeline — it all just works.

    Rails also gives you ActiveRecord, which is far more powerful than the file-based content systems most static generators use. You can model relationships between content (posts belong to categories, pages have metadata), query with scopes, and seed your database with whatever data you need. The demo app for rails2static uses a SQLite database that's committed to the repo, so the content is always available at build time.

    Scaffolds are another underrated advantage. Need an admin interface to manage content? Generate a scaffold and you have full CRUD in seconds. Exclude the admin routes from the static build with an exclude pattern, and your admin interface exists only in development.

    The trade-off is build time — Rails boots slower than Hugo. But for sites with hundreds or even a few thousand pages, the build completes in seconds. And you only pay that cost at deploy time, not on every page view.

    Rails2static bridges the gap: build with the framework you love, deploy with the simplicity of static files.
  BODY
  p.published_at = 5.hours.ago
  p.published = true
end

# Assign categories
post1.categories = [getting_started]
post2.categories = [deployment]
post3.categories = [how_it_works]
post4.categories = [getting_started, how_it_works]

# About page
Page.find_or_create_by!(slug: "about") do |p|
  p.title = "About"
  p.body = <<~BODY
    This is a demo site for rails2static, a Ruby gem that generates static sites from Rails apps.

    The site you're reading right now was built with Rails and converted to static HTML by running rake rails2static. It's deployed on Cloudflare Pages, which rebuilds it automatically on every push to the GitHub repository.

    Rails2static lets you use everything you love about Rails — ERB templates, ActiveRecord, the asset pipeline, scaffolds — while deploying as plain static files. No server to run, no database in production, no infrastructure to manage.

    Check out the source code on GitHub: https://github.com/ianterrell/rails2static
  BODY
end

puts "Seeded #{Post.count} posts, #{Category.count} categories, and #{Page.count} pages."
