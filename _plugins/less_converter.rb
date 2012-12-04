require 'less'
module Jekyll
  class LessConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /less/
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      begin
        Less::Parser.new.parse(content).to_css
      rescue Exception => e
        warn e
        raise e
      end
    end
  end
end