module FancyTools
  module ContextHelper#:nodoc:
    
    # Making Session Data Available to Models in Ruby on Rails
    # http://www.zorched.net/2007/05/29/making-session-data-available-to-models-in-ruby-on-rails/
    #
    class Base
      
      # Checks whether the missing method was a setter or getter. Delegates the
      # call to <tt>Thread.current[]</tt> or <tt>Thread.current[]=</tt>
      #
      # === Example
      #
      #    context.current_user = some_user # => Thread.current["current_user"] = some_user
      #    context.current_user             # => Thread.current["current_user"]
      #
      def method_missing(name, *args, &block)
        if name.to_s.match(/\=$/) && args.length == 1
          Thread.current[name.to_s.gsub(/\=/, "")] = args.first
        elsif args.empty?
          Thread.current[name.to_s]
        else
          puts "Method missing #{self.class.name}##{name}."
        end
      end
      
      # Delegates the call to <tt>Thread.current[]</tt>
      #
      def [] key
        Thread.current[key]
      end
      
      # Delegates the call to <tt>Thread.current[]=</tt>
      #
      def []= key, value
        Thread.current[key] = value
      end
    end
    
    # Gets the context accessor
    #
    def context_helper
      @context_helper ||= FancyTools::ContextHelper::Base.new
      @context_helper
    end
    
  end
end

::ActionController::Base.send :include, FancyTools::ContextHelper
::ActiveRecord::Base.send :include, FancyTools::ContextHelper
::ActionView::Base.send :include, FancyTools::ContextHelper