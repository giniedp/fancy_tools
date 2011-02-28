require 'fancy_tools/context_helper'
require 'fancy_tools/i18n_helper'
require 'fancy_tools/icon_helper'
require 'fancy_tools/site_map'
require 'fancy_tools/fop_helper'
require 'fancy_tools/form_builder'
require 'fancy_tools/git_helper'

module FancyTools
  class Engine < Rails::Engine
    config.fancy_tools = FancyTools

    rake_tasks do
      # load File.join(File.dirname(__FILE__), 'tasks/tasks.rake')
    end
    
    generators do
      # require File.join(File.dirname(__FILE__), "generators/some_generator.rb") 
    end
    
    initializer "fancy_tools.initialize" do |app|
    end
    
  end
end