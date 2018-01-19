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
      copy_file 'geoblacklight.scss', 'app/assets/stylesheets/geoblacklight.scss'
      copy_file 'geoblacklight.js', 'app/assets/javascripts/geoblacklight.js'

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

    def include_geoblacklight_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'include Blacklight::Solr::Document' do
        "\n include Geoblacklight::SolrDocument"
      end
    end

    def include_wms_rewrite_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'include Geoblacklight::SolrDocument' do
        "\n include include WmsRewriteConcern"
      end
    end

    def include_sidecar_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'use_extension(Blacklight::Document::DublinCore)' do
        "\ndef sidecar\n
            SolrDocumentSidecar.find_or_create_by!(document_id: id, document_type: self.class.to_s)\n
          end\n\n"
      end
    end

    def add_unique_key
      inject_into_file 'app/models/solr_document.rb', after: "# self.unique_key = 'id'" do
        "\n  self.unique_key = 'layer_slug_s'"
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

    def generate_geoblacklight_assets
      generate 'geoblacklight:assets'
    end

    def generate_geoblacklight_services
      generate 'geoblacklight:services'
    end

    def generate_geoblacklight_jobs
      generate 'geoblacklight:jobs'

      job_config = <<-"JOBS"
        config.active_job.queue_adapter = :inline
      JOBS

      inject_into_file 'config/environments/development.rb', job_config, before: /^end/
    end

    def generate_geoblacklight_uploaders
      generate 'geoblacklight:uploaders'
    end

    def bundle_install
      Bundler.with_clean_env do
        run 'bundle install'
      end
    end
  end
end
