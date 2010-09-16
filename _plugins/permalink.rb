module Jekyll
  class Post
    def template
      case self.site.permalink_style
      when :pretty
        "/:categories/:year/:month/:day/:title/"
      when :pretty_no_category
        "/:year/:month/:day/:title/"        
      when :none
        "/:categories/:title.html"
      when :date
        "/:categories/:year/:month/:day/:title.html"
      else
        self.site.permalink_style.to_s
      end
    end
  end
end