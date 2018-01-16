gem 'blacklight', '>= 6.3'
gem 'geoblacklight', github: "ewlarson/geoblacklight", branch: "feature/imagestore"

run 'bundle install'

generate 'blacklight:install', '--devise'
generate 'geoblacklight:install', '-f'

rake 'db:migrate'
