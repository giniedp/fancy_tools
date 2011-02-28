module FancyTools
  
  # Webapplications always have lots of icons in its pages. This module helps to
  # write them with a short command.
  #
  # === Example
  #    
  #    # writing this
  #    named_icon(:new_icon)
  #
  #    # gives same result as writing this
  #    image_tag("path/to/transparent/img.gif", :size=>"16x16", :class => :new_icon)
  #
  module IconHelper
  
    # Mapping of names to css class names
    mattr_accessor :class_mapping 
    @@class_mapping  = {
      :action => {
        :default => :action_icon,
        :add => :add_icon,
        :show => :show_icon,
        :new => :new_icon,
        :edit => :edit_icon,
        :delete => :delete_icon,
        :accept => :acceppt_icon,
        :success => :accept_icon,
        :reject => :cross_icon
      },
      
      :mime => {
        :default => :document_icon,
        :application => {
          :default => :document_icon,
          :pdf => :pdf_icon,
          :gzip => :archive_icon,
          :zip => :archive_icon,
          :xml => :xml_icon,
          :rtf => :word_icon,
          :msword => :word_icon,
          :msexcel => :excel_icon,
        },
        :image => {
          :default => :image_icon
        },
        :audio => {
          :default => :audio_icon
        },
        :video => {
          :default => :video_icon
        },
        :text => {
          :default => :text_icon,
          :css => :css_icon,
          :html => :html_icon,
          :rtf => :word_icon,
          :richtext => :word_icon,
          :xml => :xml_icon,
          :comma_separated_values => :excel_icon
        }
      }
    }
    
    # Mapping of names to image assets
    mattr_accessor :image_mapping
    @@image_mapping = {
      :spacer => "/images/fancygrid/spacer.gif"
    }
    
    # Mapping of names to image assets
    mattr_accessor :icon_default_options
    @@icon_default_options = {
      :size => "16x16",
      :alt => "icon"
    } 
    # Creates an image tag with an empty image source and the size option <tt>:size => 16x16</tt>.
    #
    # === Example
    #
    #    icon_tag(:class => :new_icon) 
    #    # => <img src="/images/spacer.gif" class="new_icon" width="16" height="16" alt="spacer"/>
    #
    # User the <tt>options</tt> attribute to override the default values for <tt>:size</tt> and <tt>:alt</tt>
    #
    def icon_tag( options={} )
      image_tag( get_image_path(:spacer), FancyTools::IconHelper.icon_default_options.merge(options) )
    end
    
    # Creates an <tt>icon_tag</tt> using the <tt>name</tt> for the <tt>:class</tt> option
    #
    def named_icon( name, options={} )
      icon_tag( options.merge(:class => name) )
    end
    
    # Creates an <tt>icon_tag</tt> using the <tt>name</tt> to search for a css class
    # for the <tt>:class</tt> option
    # See <tt>find_css_for_icon</tt> method for more details
    #
    def action_icon( name, options={} )
      css = get_css_class([:action, name])
      icon_tag( options.merge(:class => css) )
    end
    
    # Shortcut for <tt>action_icon(:new)</tt>
    #
    def new_icon( options={} )
      action_icon(:new, options)
    end
    
    # Shortcut for <tt>action_icon(:add)</tt>
    #
    def add_icon( options={} )
      action_icon(:add, options)
    end
       
    # Shortcut for <tt>action_icon(:add_photo)</tt>
    #
    def add_photo_icon( options={} )
      action_icon(:add_photo, options)
    end
     
    # Shortcut for <tt>action_icon(:show)</tt>
    #
    def show_icon( options={} )
      action_icon(:show, options)
    end
    
    # Shortcut for <tt>action_icon(:edit)</tt>
    #
    def edit_icon( options={} )
      action_icon(:edit, options)
    end
    
    # Shortcut for <tt>action_icon(:delete)</tt>
    #
    def delete_icon( options={} )
      action_icon(:delete, options)
    end
    
    # Creates an icon for the given mime type name.
    def mime_icon( mime_type, options={} )
      if mime_type.to_s.match(/\//)
        mime_type = [:mime, mime_type.to_s.split("/")] 
      else
        mime_type = [:mime, :default]
      end
    
      css = get_css_class(mime_type)
      icon_tag( options.merge(:class => css) )
    end
    
    def get_css_class( args )
      get_from_hash(FancyTools::IconHelper.class_mapping, args)
    end
    
    def get_image_path( args )
      get_from_hash(FancyTools::IconHelper.image_mapping, args)
    end
    
    def get_from_hash(hash, args)#:nodoc:
      last = hash
      args = [args] if (args.kind_of?(Symbol) || args.kind_of?(String))
      args = args.flatten
      args.each do |name|
        name = name.to_s.gsub("-", "_")
        next if( name.length == 0 )
        
        temp = ( last[name] or last[name.to_sym] )
        return last[:default] unless temp
        return temp unless temp.is_a?(Hash)
        last = temp
      end
      
      return last.to_s
    end
  end
end

::ActionController::Base.send :include, FancyTools::IconHelper
::ActionView::Base.send :include, FancyTools::IconHelper