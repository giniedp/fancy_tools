require "active_support/ordered_hash"

module FancyTools
  
  # Provides helper methods that help writing image tags in a shorter and more efficient command.
  # NOTE: this image tag spits out an image with a transparent pixel. The styling must be done in the css depend in the class attribute
  module IconHelper
  
    mattr_accessor :mime_mapping 
    @@mime_mapping = ActiveSupport::OrderedHash.new()
    @@mime_mapping[:document] = [/^application\//]
    @@mime_mapping[:image]    = [/^image/]
    @@mime_mapping[:audio]    = [/^audio/]
    @@mime_mapping[:video]    = [/^video/]
    @@mime_mapping[:text]     = [/^text/]
    @@mime_mapping[:pdf]      = [/^(application\/)?pdf/]
    @@mime_mapping[:archive]  = [/^(application\/)?(zip|gzip)/]
    @@mime_mapping[:xml]      = [/^((application|text)\/)?xml/]
    @@mime_mapping[:word]     = [/^(application\/)?(msword|rtf|vnd\.ms-word|vnd\.openxmlformats\-officedocument\.wordprocessingml)/]
    @@mime_mapping[:excel]    = [/^(application\/)?(msexcel|vnd\.ms-excel|vnd\.openxmlformats\-officedocument\.spreadsheetml)/]
    @@mime_mapping[:ppt]      = [/^(application\/)?(ppt|powerpoint|vnd\.ms-powerpoint|vnd\.openxmlformats\-officedocument\.presentationml)/]
    @@mime_mapping[:html]     = [/^(text\/)?html/]
    
    mattr_accessor :default_size
    @@default_size = "16x16"
    
    mattr_accessor :default_alt_attribute
    @@default_css_class = "icon"
    
    mattr_accessor :default_class_attribute
    @@default_css_class = "default"
    
    mattr_accessor :additional_class_attribute
    @@additional_class_attribute = "icon"
    
    # Creates an image tag with a transparent image
    #
    # === Example
    #
    #    icon_tag
    #    # => <img src="data:image/gif;base64,R0lGODlhAQABAIAAAMDAwAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw%3D%3D" class="default icon" width="16" height="16" alt="icon"/>
    #
    #    icon_tag(:icon_name)
    #    # => <img src="data..." class="icon_name icon" width="16" height="16" alt="icon"/>
    #
    #    # the following method calls are equivalent
    #    icon_tag(:class => "foo bar")
    #    icon_tag(:foo, :class => :bar)
    #    icon_tag(:foo, :bar)
    #    icon_tag(:foo, :bar, :icon)
    #    # => <img src="data..." class="foo bar icon" width="16" height="16" alt="icon"/>
    #
    #    icon_tag(:icon_name, :alt => "alt attribute")
    #    # => <img src="data..." class="icon_name icon" width="16" height="16" alt="alt attribute"/>
    #
    #    icon_tag(:icon_name, :size => 10)
    #    icon_tag(:icon_name, :size => "10x10")
    #    # => <img src="data..." class="icon_name icon" width="10" height="10" alt="icon"/>
    #
    def icon_tag(*args)      
      options = args.extract_options!
      options.symbolize_keys!
      options[:title] ||= options[:alt]
      options[:alt] ||= (options[:title] || IconHelper.default_alt_attribute)
      options[:src] ||= "data:image/gif;base64,R0lGODlhAQABAIAAAMDAwAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw%3D%3D"
      if (size = (options.delete(:size) || IconHelper.default_size).to_s)
        options[:width], options[:height] = size.split("x") if size =~ /^\d+x\d+$/
        options[:width] = options[:height] = size if size =~ /^\d+$/
      end
      
      css_class = args + options[:class].to_s.split(" ")
      if css_class.empty?
        css_class = [IconHelper.default_class_attribute]
      end
      css_class << IconHelper.additional_class_attribute
      options[:class] = css_class.compact.uniq.join(" ")
      tag("img", options)
    end
    
    # Shortcut for <tt>icon_tag(:action, :new, options)</tt>
    def new_icon( options={} )
      icon_tag(:new, options)
    end
    
    # Shortcut for <tt>icon_tag(:action, :add, options)</tt>
    def add_icon( options={} )
      icon_tag(:add, options)
    end
       
    # Shortcut for <tt>icon_tag(:action, :add_photo, options)</tt>
    def add_photo_icon( options={} )
      icon_tag(:add_photo, options)
    end
     
    # Shortcut for <tt>icon_tag(:action, :show, options)</tt>
    def show_icon( options={} )
      icon_tag(:show, options)
    end
    
    # Shortcut for <tt>icon_tag(:action, :edit, options)</tt>
    def edit_icon( options={} )
      icon_tag(:edit, options)
    end
    
    # Shortcut for <tt>icon_tag(:action, :delete, options)</tt>
    def delete_icon( options={} )
      icon_tag(:delete, options)
    end
    
    # Creates an icon for the given mime type name.
    def mime_icon( mime, options={} )
      name = :document
      IconHelper.mime_mapping.keys.each do |key|
        name = key if IconHelper.mime_mapping[key].any? { |regex| mime.to_s =~ regex }
      end
      icon_tag(name, options )
    end

  end
end

::ActionController::Base.send :include, FancyTools::IconHelper
::ActionView::Base.send :include, FancyTools::IconHelper