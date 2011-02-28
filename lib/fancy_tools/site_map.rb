module FancyTools
  module SiteMap
    
    # Creates a menu item at the specified path.
    #
    # === Example
    #    
    #    menu_item("navigation.foo", :url => "/foo")
    #
    # The example will create the menu item 'foo' at the 'navigation' branch and 
    # give it the "/foo" url. See the <tt>menu</tt> method for more details
    def menu_item(path, options=nil)
      menu_item = menu(path)
      menu_item.set_options(options) if options
      #menu_item.selected = !request.path.to_s.match(options[:url].to_s).nil?
      menu_item
    end
    
    # Returns the menu items for the given path. If the path does not exis it will
    # be created. In that case the path will contain an empty colleciton of menu items
    #
    # === Example
    #
    #    menu_item("navigation.foo", :url => "/foo")
    #    menu_item("navigation.bar", :url => "/bar")
    #    menu("navigation")
    #
    # The example will create two menu items for the navigation branch. The last 
    # call gets all menu items for the navigation branch.
    def menu(path=nil)
      @current_site_map ||= FancyTools::SiteMap::Item.new(:root)
      menu_item = @current_site_map
      path.to_s.split(/\./).each do |p|
        menu_item = menu_item[p]
      end
      menu_item
    end
    
    class Item
      
      # Collection of child menu items
      #
      attr_accessor :menu_items
      
      # An instance of <tt>SiteMap::Item</tt> that is the parent element
      # of this menu item
      #
      attr_accessor :parent
      
      # The name of this menu item
      #
      attr_accessor :name
      
      # The icon name to render with this menu item
      #
      attr_accessor :icon
      
      # The url or path where this menu item links to
      #
      attr_accessor :url
      
      # A value indicating whether this menu item is selected or not
      #
      attr_accessor :selected
      
      # Creates a new instance of <tt>SiteMap::Item</tt>
      #
      # === Arguments
      #
      #    <tt>name</tt> - The name of this menu item
      #    <tt>parent</tt> - The parent menu item
      #    <tt>options</tt> - Some initialization options
      #
      # === Options
      #
      #    <tt>icon</tt> - The icon name to render with this menu item
      #    <tt>url</tt> - The url or path where this menu item links to
      #    <tt>selected</tt> - A value indicating whether this menu item is selected or not
      #
      def initialize(name, parent=nil, options=nil)
        option ||= {}
        self.menu_items = {}
        self.parent = parent
        self.name = name
        self.set_options(options)
      end
      
      # Applies the passed options to this item
      #
      # === Options
      #
      #    <tt>icon</tt> - The icon name to render with this menu item
      #    <tt>url</tt> - The url or path where this menu item links to
      #    <tt>selected</tt> - A value indicating whether this menu item is selected or not
      #
      def set_options opts=nil
        opts ||= {}
        self.icon     = opts[:icon]     unless opts[:icon].nil?
        self.url      = opts[:url]      unless opts[:url].nil?
        self.selected = opts[:selected] unless opts[:selected].nil?
      end
      
      # Returns the translated human name of this item.
      #
      def human_name
        @human_name ||= I18n.translate("site_map.#{self.tree_path}.name", :default => self.name.to_s.humanize)
        @human_name
      end
      
      # Adds a new child item
      #
      def add_item name, options=nil
        self.get_item(name)
        self.get_item(name).set_options(options)
      end
      
      # Gets an existing child item for the given name or creates a new one
      #
      def get_item name
        raise "Invalid SiteMap::Item name. Names must not contain dots '#{name}'" if name.to_s.include?(".")
        self.menu_items[name] ||= SiteMap::Item.new(name, self)
        self.menu_items[name]
      end
      
      # Gets an existing child item for the given name or creates a new one
      #
      def [] name
        self.get_item(name)
      end
      
      # Replaces an existing child item with given value
      #
      def []= name, value
        self.menu_items[name] = value
      end
      
      # Iterates over each child item and calls the passed block
      #
      def each &block
        self.menu_items.each do |name, item|
          yield(item)
        end
      end
      
      # Removes all child and parent items from this instance
      def clear
        self.parent = nil
        self.menu_items = {}
      end
      
      # Returns the first child item that is <tt>selected</tt>
      #
      def current
        self.menu_items.each do |key, item|
          return item if item.selected
        end
        
        SiteMap::Item.new("")
      end
      
      # Returns <tt>active</tt> if this item is <tt>selected</tt> otherwise an empty string
      #
      def active_class
        self.selected ? "active" : ""
      end
      
      # Returns a string with all names that are in the same branch as this node
      # connected with a <tt>.</tt> (dot)
      #
      def tree_path
        if parent.respond_to?(:tree_path)
          "#{parent.tree_path}.#{self.name}"
        else
          self.name
        end
      end
      
      # Calculates the number of nodes in the branch starting from root and excluding self.
      #
      def depth
        @depth ||= tree_path.split(/\./).length - 1
        @depth
      end
      
      # Dumps the current subtree into a string. This is helpful for debugging a sitemap
      #
      def dump(prefix=nil, stream=nil)
        stream ||= ""
        prefix ||= ""
      
        if self.url.blank?
          stream << "#{prefix}+-#{self.name}\n"
        else
          stream << "#{prefix}+-#{self.name} => { #{self.dump_options} }\n"
        end
        
        self.each do |item|
          (item.dump(prefix + "| ", stream) + "\n")
        end
        stream
      end
      
      # Dumps the options of current note into a string
      #
      def dump_options
        result = ""
        result << ":url => '#{self.url}', " if self.url
        result << ":icon => '#{self.icon}', " if self.icon
        result << ":selected => '#{self.selected}', " if self.selected
        result
      end
      
      def setup_current_state current_path
        self.propagate_options(:down, :selected => false)
        best_match = self.get_deepest_match(current_path)
        if best_match
          best_match.propagate_options(:up, :selected => true)
        end
      end
      
      def get_deepest_match(current_path, current_match=nil)
        if current_path.starts_with?(self.url)
          current_match = self if(current_match.nil? || (self.depth > current_match.depth))
        end
        self.each do |child|
          current_match = child.get_deepest_match(current_path, current_match)
        end
        return current_match
      end

      def propagate_options direction, options
        self.set_options(options)
        
        if (direction == :up)
          self.parent.propagate_options(direction, options) if self.parent
        else 
          self.each do |child|
            child.propagate_options(direction, options)
          end
        end
      end

      def exclude *names
        names.map!{ |name| name.to_s }
        result = []
        self.each do |child|
          result << child unless names.include?(child.name)
        end
        result
      end
      
      def only *names
        names.map!{ |name| name.to_s }
        result = []
        self.each do |child|
          result << child if names.include?(child.name)
        end
        result
      end
      
    end 
  end
end

::ActionController::Base.send :include, FancyTools::SiteMap
::ActionView::Base.send :include, FancyTools::SiteMap