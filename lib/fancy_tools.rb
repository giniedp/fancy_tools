require 'rails'
require 'action_controller'
require 'fancy_tools'

require 'fancy_tools/rails'

module FancyTools

  def self.setup
    yield self
  end
  
end
