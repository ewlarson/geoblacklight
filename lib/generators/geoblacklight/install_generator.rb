require 'rails/generators'

module Geoblacklight
  class Install < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Install Geoblacklight'

    def mount_geoblacklight_engine
      inject_into_file 'config/routes.rb', "mount Geoblacklight::Engine => 'geoblacklight'\n", before: /^end/
    end

    def inject_geoblacklight_routes
      routes = <<-"ROUTES"
        concern :gbl_exportable, Geoblacklight::Routes::Exportable.new
        resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
          concerns :gbl_exportable
        end
        concern :gbl_wms, Geoblacklight::Routes::Wms.new
        namespace :wms do
          concerns :gbl_wms
        end
        concern :gbl_downloadable, Geoblacklight::Routes::Downloadable.new
        namespace :download do
          concerns :gbl_downloadable
        end
        resources :download, only: [:show]
      ROUTES

      inject_into_file 'config/routes.rb', routes, before: /^end/
    end

    def assets
      append_to_file 'config/initializers/assets.rb',
                     "\nRails.application.config.assets.precompile += %w( favicon.ico )\n"
    end

    def create_blacklight_catalog
      remove_file 'app/controllers/catalog_controller.rb'
      copy_file 'catalog_controller.rb', 'app/controllers/catalog_controller.rb'
    end

    def rails_config
      copy_file 'settings.yml', 'config/settings.yml'
    end

    def solr_config
      directory '../../../../solr', 'solr'
    end

    def devise_initializer
      copy_file 'devise.rb', 'config/initializers/devise.rb'
    end

    def add_carrierwave_require
      inject_into_file 'config/application.rb', after: "require 'rails/all'" do
        "\n  require 'carrierwave'"
      end
    end

    def add_spatial_search_behavior
      inject_into_file 'app/models/search_builder.rb', after: 'include Blacklight::Solr::SearchBuilderBehavior' do
        "\n  include Geoblacklight::SpatialSearchBehavior"
      end
    end

    def create_downloads_directory
      FileUtils.mkdir_p('tmp/cache/downloads') unless File.directory?('tmp/cache/downloads')
    end

    def generate_geoblacklight_assets
      generate 'geoblacklight:assets'
    end

    def generate_geoblacklight_services
      generate 'geoblacklight:services'
    end

    def generate_geoblacklight_jobs
      generate 'geoblacklight:jobs'
    end

    def generate_geoblacklight_models
      generate 'geoblacklight:models'
    end

    def generate_geoblacklight_uploaders
      generate 'geoblacklight:uploaders'
    end

    def generate_geoblacklight_example_docs
      generate 'geoblacklight:example_docs'
    end

    def bundle_install
      Bundler.with_clean_env do
        run 'bundle install'
      end
    end
  end
end
