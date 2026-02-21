require "fileutils"

module Rails2static
  class Writer
    def initialize(config: Rails2static.configuration)
      @config = config
    end

    def write_pages(pages)
      pages.each { |page| write_page(page) }
    end

    def write_assets(assets)
      assets.each { |asset| write_asset(asset) }
    end

    def copy_public(public_dir)
      return unless File.directory?(public_dir)

      Dir.glob(File.join(public_dir, "**", "*")).each do |file|
        next if File.directory?(file)

        relative = file.sub("#{public_dir}/", "")
        dest = File.join(@config.output_dir, relative)

        next if File.exist?(dest)

        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(file, dest)
      end
    end

    private

    def write_page(page)
      dest = destination_for(page)
      FileUtils.mkdir_p(File.dirname(dest))

      if page.binary?
        File.binwrite(dest, page.body)
      else
        File.write(dest, page.body)
      end
    end

    def write_asset(asset)
      dest = File.join(@config.output_dir, asset.path)
      FileUtils.mkdir_p(File.dirname(dest))

      if asset.binary?
        File.binwrite(dest, asset.body)
      else
        File.write(dest, asset.body)
      end
    end

    def destination_for(page)
      path = page.path

      if path == "/"
        return File.join(@config.output_dir, "index.html")
      end

      if page.html?
        if @config.trailing_slash
          File.join(@config.output_dir, path, "index.html")
        else
          File.join(@config.output_dir, "#{path}.html")
        end
      else
        File.join(@config.output_dir, path)
      end
    end
  end
end
