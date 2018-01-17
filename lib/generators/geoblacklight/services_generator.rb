# frozen_string_literal: true
require 'rails/generators'

module Geoblacklight
  class ServicesGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc <<-EOS
      This generator makes the following changes to your application:
       1. Creates a app/services directory
       2. Creates service models within the app/services directory
    EOS

    def create_services
      directory "services", "app/services"
    end
  end
end
