require 'rexml/document'

class TinyXPathHelper
  attr :node

  def initialize(xml)
    @xml  = xml
    @node = self.class.xml_node_for_xmlish(xml)
  end
  
  def find_xpath(xpath_expr, options = {})
    self.class.find_xpath_from( node, xpath_expr, options )
  end

  alias at find_xpath

  def first(xpath_expr, options = {})
    self.find_xpath( xpath_expr, options.update(:find => :first) )
  end

  def all(xpath_expr, options = {})
    self.find_xpath( xpath_expr, options.update(:find => :all) )
  end
  alias [] all

  def self.io_stream_classes
    [ IOStream ] rescue [ IO, StringIO ] # thoughtbot-paperclip fixes the ducktype mess here
  end

  def self.classes_that_are_xmlish
    io_stream_classes + [ String, REXML::Document ]
  end

  def self.xml_node_for_xmlish( xml )
    if io_stream_classes.any?{|k| k === xml }
      xml = xml.read
    end
    if String === xml
      xml = REXML::Document.new(xml)
    end
    if REXML::Document === xml
      xml = xml.root
    end
    if not REXML::Element === xml
      raise TypeError.new("Expected REXML::Element, got #{xml.class}")
    end
    return xml
  end

  def self.xml_node_to_text(node)
    if(node.respond_to? :text)
      # XML::Elements don't to_s in the way we want
      val = node.text
    else
      val = node.to_s
    end
  end

  def self.find_xpath_from(element, path, options = {}, &blk)

    format = options[:format] || :text
    if format == :array
      options.update( :format => :text, :find => :all )
    end

    count = options[:find] || :first

    if format == :text
      filter = self.method(:xml_node_to_text)
    elsif format == :xml
      filter = lambda{|node| node }
    else
      raise "I don't know the format #{format.inspect}"
    end

    if count == :all
      val = REXML::XPath.match(element, path).map do |node|
        filter.call( node )
      end
    elsif count == :first
      val = filter.call(
        REXML::XPath.first(element, path)
      )
    else 
      raise "I don't know how to find #{count.inspect}"
    end

    if(blk)
      return val if val == nil or val == []
      return blk.call(val)
    end
    return val
  end

end

TinyXpathHelper = TinyXPathHelper
