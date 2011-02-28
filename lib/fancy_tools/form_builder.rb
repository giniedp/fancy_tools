require "simple_form"

module FancyTools
  
  class FormBuilder < SimpleForm::FormBuilder
    def input(attribute_name, options={}, &block)
      # gsub things like this
      #   company[manager_attributes][person_attributes][contact_attributes]
      # to this
      #   company.manager.person.contact
      name = self.object_name.to_s.gsub(/\[/, '.').gsub(/\]/, '').gsub(/_attributes/, '')
      
      lookups = []
      lookups << :"#{name}.#{attribute_name}"
      
      tooltip = I18n.t(lookups.shift, :scope => :"simple_form.tooltips", :default => "")
            
      options[:input_html] ||= {}
      options[:input_html][:title] = tooltip
      
      super(attribute_name, options, &block)
    end
  end
  
  module FormHelper
    def fancy_form_for(object, *args, &block)
      if args.last.is_a? Hash
        args.last[:builder] = FormBuilder
      else
        args << { :builder => FormBuilder }
      end
      simple_form_for(object, *(args), &block)
    end
  end
  
  module FormExtensions
    def fancy_fields_for(*args, &block)
      options = args.extract_options!
      options[:builder] = self.class
      fields_for(*(args << options), &block)
    end
  end
  
end

ActionView::Base.send :include, FancyTools::FormHelper
ActionView::Helpers::FormBuilder.send :include, FancyTools::FormExtensions
