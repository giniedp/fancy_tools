require 'active_support/core_ext/hash/reverse_merge'

module FancyTools
  module I18nHelper
    module ActiveRecord
      
      def tooltip_options_for(attribute, options={})
        tip = self.tooltip_for(attribute, options)
        if tip.blank?
          {}
        else
          { :title => tip }
        end
      end
      
      # Transforms attribute names into tooltips, such as "The first name of a user"
      # instead of "first_name".
      # <tt>activerecord.tooltips.CLASSNAME.TITLE</tt>
      # <tt>tooltips.CLASSNAME.TITLE</tt>
      #
      #   Person.tooltip_for("first_name") # => "The first name of a user"
      #
      # Specify +options+ with additional translating options.
      def tooltip_for(attribute, options = {})
        defaults = lookup_ancestors.map do |klass|
          :"#{self.i18n_scope}.tooltips.#{klass.model_name.i18n_key}.#{attribute}"
        end
      
        defaults << :"tooltips.#{attribute}"
        defaults << options.delete(:default) if options[:default]
        defaults << ""
      
        options.reverse_merge! :count => 1, :default => defaults
        I18n.translate(defaults.shift, options)
      end
      
      # Transforms button names into readable names, such as "Back to users"
      # instead of "back".
      # <tt>activerecord.buttons.CLASSNAME.TITLE</tt>
      # <tt>buttons.CLASSNAME.TITLE</tt>
      #
      #   Person.human_button_name("back") # => "Back to people index"
      #
      # Specify +options+ with additional translating options.
      def human_button_name(button_name, options = {})
        defaults = lookup_ancestors.map do |klass|
          :"#{self.i18n_scope}.buttons.#{klass.model_name.i18n_key}.#{button_name}"
        end
      
        defaults << :"buttons.#{button_name}"
        defaults << options.delete(:default) if options[:default]
        defaults << button_name.to_s.humanize
      
        options.reverse_merge! :default => defaults
        I18n.translate(defaults.shift, options)
      end
      
      # Transforms action names into readable titles, such as "Listing users"
      # instead of "index".
      # <tt>activerecord.actions.CLASSNAME.TITLE</tt>
      # <tt>actions.CLASSNAME.TITLE</tt>
      #
      #   User.human_action_name("index") # => "Listing users"
      #
      # Specify +options+ with additional translating options.
      def human_action_name(action, options = {})
        defaults = lookup_ancestors.map do |klass|
          :"#{self.i18n_scope}.actions.#{klass.model_name.i18n_key}.#{action}"
        end
      
        defaults << :"actions.#{action}"
        defaults << options.delete(:default) if options[:default]
        defaults << action.to_s.humanize
      
        options.reverse_merge! :default => defaults
        I18n.translate(defaults.shift, options)
      end
      
      # Transforms action names into readable titles, such as "Listing users"
      # instead of "index". Possible I18n pathes are
      # <tt>activerecord.titles.CLASSNAME.TITLE</tt>
      # <tt>titles.CLASSNAME.TITLE</tt>
      #
      #   User.human_action_name("index") # => "Listing users"
      #
      # Specify +options+ with additional translating options.
      def human_title_name(action, options = {})
        defaults = lookup_ancestors.map do |klass|
          :"#{self.i18n_scope}.titles.#{klass.model_name.i18n_key}.#{action}"
        end
      
        defaults << :"titles.#{action}"
        defaults << options.delete(:default) if options[:default]
        defaults << action.to_s.humanize
      
        options.reverse_merge! :default => defaults
        I18n.translate(defaults.shift, options)
      end
    end
  end
end

::ActiveRecord::Base.extend(FancyTools::I18nHelper::ActiveRecord)