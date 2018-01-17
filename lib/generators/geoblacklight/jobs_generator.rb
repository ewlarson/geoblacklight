# frozen_string_literal: true
require 'rails/generators'

module Geoblacklight
  class JobsGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc <<-EOS
      This generator makes the following changes to your application:
       1. Copies jobs files to host app/jobs
    EOS

    def create_store_image_jobs
      copy_file "jobs/store_image_job.rb", "app/jobs/store_image_job.rb"
    end
  end
end
