require 'daemons'
Daemons.run('rake migrate:data RAILS_ENV=production')