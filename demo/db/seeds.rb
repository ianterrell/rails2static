# Categories
ruby = Category.find_or_create_by!(name: "Ruby", slug: "ruby")
travel = Category.find_or_create_by!(name: "Travel", slug: "travel")
tutorials = Category.find_or_create_by!(name: "Tutorials", slug: "tutorials")

# Posts
post1 = Post.find_or_create_by!(slug: "getting-started-with-ruby") do |p|
  p.title = "Getting Started with Ruby"
  p.body = <<~BODY
    Ruby is a dynamic, open-source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.

    Created by Yukihiro "Matz" Matsumoto in the mid-1990s, Ruby has grown into one of the most popular languages in the world, largely thanks to the Ruby on Rails web framework.

    Here are a few things that make Ruby special:

    Everything is an object. In Ruby, every piece of data is an object, including numbers and even nil. This consistency makes the language predictable and fun to work with.

    Blocks and iterators are first-class citizens. Ruby's block syntax lets you write expressive, readable code for iteration and callbacks.

    The community is welcoming. Rubyists follow the principle of MINASWAN — "Matz is nice and so we are nice." The community is known for being friendly and helpful to newcomers.

    If you're just getting started, I'd recommend installing Ruby via rbenv or asdf, then working through the official Ruby in Twenty Minutes tutorial.
  BODY
  p.published_at = 3.days.ago
  p.published = true
end

post2 = Post.find_or_create_by!(slug: "why-static-sites-still-matter") do |p|
  p.title = "Why Static Sites Still Matter"
  p.body = <<~BODY
    In an era of complex JavaScript frameworks and server-side rendering, static sites might seem like a step backward. But they offer compelling advantages that make them the right choice for many projects.

    Performance is the most obvious benefit. Static files served from a CDN load incredibly fast. There's no database query, no server-side rendering, no API call — just HTML delivered straight to the browser.

    Security is another major win. With no server-side code executing, the attack surface shrinks dramatically. There's no SQL injection, no server-side request forgery, no authentication bypass. The site is just files.

    Hosting costs drop to nearly zero. You can host a static site on GitHub Pages, Netlify, or an S3 bucket for free or pennies per month.

    The key insight behind rails2static is that you don't have to give up your favorite tools to get these benefits. Write your site in Rails with all the conveniences you love — ERB templates, ActiveRecord, the asset pipeline — then generate static output for production.
  BODY
  p.published_at = 1.day.ago
  p.published = true
end

post3 = Post.find_or_create_by!(slug: "a-week-in-tokyo") do |p|
  p.title = "A Week in Tokyo"
  p.body = <<~BODY
    Tokyo is a city that defies expectations at every turn. Ancient temples sit in the shadow of neon-lit skyscrapers. Quiet residential streets open onto bustling shopping districts. The food ranges from hundred-year-old ramen shops to three-Michelin-star sushi counters.

    Day 1-2: Shibuya and Harajuku. Start with the iconic Shibuya crossing, then wander through Harajuku's Takeshita Street. Visit Meiji Shrine for a moment of calm amid the city buzz.

    Day 3: Asakusa and Akihabara. Senso-ji temple in Asakusa is Tokyo's oldest, and the surrounding Nakamise shopping street is perfect for souvenirs. Then head to Akihabara for electronics and otaku culture.

    Day 4-5: Day trips. Take the Shinkansen to Kamakura to see the Great Buddha, or head to Nikko for ornate shrines surrounded by cedar forests.

    Day 6-7: Shinjuku and beyond. Explore Shinjuku Gyoen garden, get lost in Golden Gai's tiny bars, and catch sunset from the Tokyo Metropolitan Government Building's free observation deck.

    Pro tip: Get a Suica card at the airport. It works on all trains and buses and can even be used at convenience stores.
  BODY
  p.published_at = 5.hours.ago
  p.published = true
end

post4 = Post.find_or_create_by!(slug: "building-a-static-site-generator") do |p|
  p.title = "Building a Static Site Generator with Rails"
  p.body = <<~BODY
    One of the best things about Rails is how quickly you can build a content-driven site. But deploying a full Rails app just to serve what is essentially static content feels like overkill.

    That's the motivation behind rails2static. It crawls your Rails app using Rack::Test, following links from a set of entry points, and writes out plain HTML files. The result is a static site that can be deployed anywhere.

    Here's how it works:

    1. You develop your site as a normal Rails app with models, views, and controllers.
    2. You add rails2static to your Gemfile and configure it with an initializer.
    3. You run rake rails2static, which boots your app, crawls all the pages, and writes them to a _site directory.
    4. You deploy the _site directory to any static hosting provider.

    The crawler is smart about following links. It parses each page with Nokogiri, extracts all internal links, and adds them to a queue. It respects your exclude patterns so admin pages and other dynamic routes don't get crawled.

    This approach gives you the best of both worlds: the developer experience of Rails with the performance and simplicity of static hosting.
  BODY
  p.published_at = 2.days.ago
  p.published = true
end

# Assign categories
post1.categories = [ruby, tutorials]
post2.categories = [ruby, tutorials]
post3.categories = [travel]
post4.categories = [ruby, tutorials]

# About page
Page.find_or_create_by!(slug: "about") do |p|
  p.title = "About"
  p.body = <<~BODY
    Welcome to my blog! I'm a software developer who loves Ruby, traveling, and sharing what I learn.

    This blog is built with Ruby on Rails and converted to a static site using rails2static. It's a demonstration of how you can use your favorite web framework for content sites without the overhead of running a server in production.

    The source code for both rails2static and this demo blog is available on GitHub. Feel free to use it as a starting point for your own projects.
  BODY
end

puts "Seeded #{Post.count} posts, #{Category.count} categories, and #{Page.count} pages."
