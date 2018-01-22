# frozen_string_literal: true
require 'rails/generators'

module Geoblacklight
  class AssetsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc <<-EOS
      This generator makes the following changes to your application:
       1. Copies asset image files to host app/assets/images
       2. Copies asset javascript files to host app/assets/javascripts
       3. Copies asset stylesheet files to host app/assets/stylesheets
    EOS

    # Necessary for bootstrap-sass 3.2
    def inject_sprockets
      blacklight_css = Dir['app/assets/stylesheets/blacklight.scss'].first
      if blacklight_css
        insert_into_file blacklight_css, before: "@import 'bootstrap';" do
          "@import 'bootstrap-sprockets';\n"
        end
      else
        say_status 'warning', 'Can not find blacklight.scss, did not insert our require', :red
      end
    end

    def disable_turbolinks
      gsub_file('app/assets/javascripts/application.js', %r{\/\/= require turbolinks}, '')
    end

    def create_javascripts_assets
      copy_file "assets/javascripts/geoblacklight.js", "assets/javascripts/geoblacklight.js"
    end

    def create_stylesheets_assets
      copy_file "assets/stylesheets/geoblacklight.scss", "app/assets/stylesheets/geoblacklight.scss"
    end

    def create_images_assets
      copy_file "assets/images/thumbnail-image.png", "app/assets/images/thumbnail-image.png"
      copy_file "assets/images/thumbnail-line.png", "app/assets/images/thumbnail-line.png"
      copy_file "assets/images/thumbnail-mixed.png", "app/assets/images/thumbnail-mixed.png"
      copy_file "assets/images/thumbnail-multipoint.png", "app/assets/images/thumbnail-multipoint.png"
      copy_file "assets/images/thumbnail-paper-map.png", "app/assets/images/thumbnail-paper-map.png"
      copy_file "assets/images/thumbnail-point.png", "app/assets/images/thumbnail-point.png"
      copy_file "assets/images/thumbnail-polygon.png", "app/assets/images/thumbnail-polygon.png"
      copy_file "assets/images/thumbnail-raster.png", "app/assets/images/thumbnail-raster.png"
    end
  end
end
