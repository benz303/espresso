require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'yaml'
require File.expand_path('../config', __FILE__)

Cfg = AppConfig.new

Bundler.require(Cfg.env)

require Cfg.app_path('database.rb')

App = EspressoApp.new(:automount)
App.controllers_setup do
  view_path 'app/views'
end

App.assets_url 'assets'
App.assets.prepend_path Cfg.assets_path

Dir[Cfg.helpers_path + '*.rb'].each {|file| require file}

[Cfg.models_path, Cfg.controllers_path].each do |path|
  extra = Dir[path + '*.rb'].inject([]) do |files,file|
    require file
    files.concat Dir[file.sub(/(\.rb)\Z/, '/*\1')]
  end
  extra.each {|f| require f}
end

DataMapper.finalize if Cfg.db[:orm] == :DataMapper