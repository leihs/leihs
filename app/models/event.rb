# Timeline event

class Event < ActiveRecord::Base
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :start, :date, Date.today
  column :end, :date, Date.today
  column :title, :string, ""
  column :isDuration, :boolean, true
  column :action, :string, "hand_over"
  column :quantity, :integer, 0

  has_one :inventory_pool
  has_one :user
  has_many :contract_lines                

  # alias
  def lines
    contract_lines
  end

  #alias
  def date
    start
  end
  
  def quantity
    self.contract_lines.collect(&:quantity).sum
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.date <=> other.date
  end  

############################################################################
# Timeline

  require 'rexml/document'
  include REXML

  def to_xml
    xml = Document.new()
    e = Element.new("event")
    e.attributes["start"] = self.start.strftime("%c %Z")
    e.attributes["end"] = self.end.strftime("%c %Z")
    e.attributes["title"] = self.title
    e.attributes["isDuration"] = self.isDuration
    e.attributes["icon"] = "api/images/dull-red-circle.png" if self.action == "take_back"
    e.text = "" # TODO description
    xml << e
    xml
  end


  def self.xml_wrap(events)
    xml = Document.new()
    @d = Element.new("data")
    events.each do |e|
      @d << e.to_xml  
    end
    xml << @d
    xml
  end

end

