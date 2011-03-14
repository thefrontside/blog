require 'pathname'
require 'yaml'

module Jekyll
  def self.root
    @root ||= Pathname(File.expand_path(File.dirname(__FILE__) + '/..'))
  end
  
  class Author < Liquid::Tag
    MissingAuthor = Class.new(StandardError)
    @authors_path = Jekyll.root.join("_authors")

    attr_reader :data

    def initialize(name, properties)
      @name = name
      @data = properties      
    end
    
    # Give liquid a hash of our values
    def to_liquid
      @data
    end
    
    # Authors are equal if they all talk about the same data
    def ==(anOther)
      @data == anOther.data
    end
    
    # Always defer anything extra to the data
    def method_missing(name, *args)
      @data[name.to_s]
    end
    
    # Create a new Author instance from a given handle via a YAML file
    def self.[](name)
      @authors_path.join("#{name}.yaml").tap do |author_path|
        if author_path.exist?
          return Author.new(name, YAML.load(author_path.read))
        else
          fail MissingAuthor, "author '#{name}' not found"
        end
      end
    end
  end

  class Post
    # Hide the previous to_liquid method for later
    alias_method :old_to_liquid, :to_liquid
    
    def author
      if name = self.data['author']
        Author[name]
      end
    end

    # Merge author hash into this one
    def to_liquid
      old_to_liquid.merge! self.data.deep_merge({
        "author" => self.author
      })
    end

  end
  
  class AuthorAtoms < Generator
    safe true
    priority :low
    
    puts "Generating atoms..."
    def generate(site)
      # Find all authors
      authors = []
      site.posts.each do |post|
        if !authors.include?(post.author)
          authors << post.author
        end
      end

      # Generate an atom.xml for each user
      # They will be placed in /atom/handle.xml
      atom_dir = File.join(site.source, 'atom') 
      Dir.mkdir atom_dir if !Dir.exist? atom_dir
      authors.each do |author|
        # Create a simple atom file
        File.open(File.join(atom_dir, "#{author.handle}.xml"), "w") do |file|
          file.write "---\n"
          file.write "layout: atom\n"
          file.write "author: #{author.handle}\n"
          file.write "---\n"
        end
      end
      
      # Have Jekyll process these new pages
      site.read_directories('atom')
    end
  end
end

Liquid::Template.register_tag('author', Jekyll::Author)