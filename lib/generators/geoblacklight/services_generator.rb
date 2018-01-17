# frozen_string_literal: true
require 'rails/generators'

module GeoBlacklight
  class ServicesGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    desc <<-EOS
      This generator makes the following changes to your application:
       1. Creates a app/services directory
       1. Creates service models within the app/services directory
    EOS

    def create_solr_document
      template "solr_document.rb", "app/services/#{model_name}.rb"
    end

    def create_solr_document
      template "solr_document.rb", "app/services/#{model_name}.rb"
    end
  end
end
