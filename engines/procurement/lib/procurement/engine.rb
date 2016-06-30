require 'rails-assets-bootstrap'
require 'rails-assets-jquery-tokeninput'
# require 'rails-assets-bootstrap-multiselect'
# require "font-awesome-sass"
require 'acts_as_tree'
require 'paperclip'
require 'pundit'
require 'remotipart'

module Procurement
  class Engine < ::Rails::Engine
    isolate_namespace Procurement

    initializer 'engine.assets.precompile' do |app|
      app.config.assets.precompile += %w(procurement/application.css
                                         procurement/application.js)
    end

  end
end
