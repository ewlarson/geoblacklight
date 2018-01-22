# frozen_string_literal: true
require 'rails/generators'
require 'rails/generators/migration'

module Geoblacklight
  class ModelsGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    desc <<-EOS
      This generator makes the following changes to your application:
       1. Injects Geoblacklight into SolrDocument
       2. Adds SolrDocumentSidecar ActiveRecord model
    EOS

    # Setup the database migrations
    def copy_migrations
      rake "geoblacklight_engine:install:migrations"
    end

    def include_geoblacklight_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'include Blacklight::Solr::Document' do
        "\n include Geoblacklight::SolrDocument"
      end
    end

    def include_wms_rewrite_solrdocument
      inject_into_file 'app/models/solr_document.rb', after: 'include Geoblacklight::SolrDocument' do
        "\n include WmsRewriteConcern"
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

    def create_store_image_jobs
      copy_file "models/solr_document_sidecar.rb", "app/models/solr_document_sidecar.rb"
    end
  end
end
