require 'hashie/mash'
require 'csv'

class Hilo
  require_relative File.join(File.dirname(__FILE__), "hilofields.lua")
  INPUT_FIELDS = HILOFIELDS.split(",").map {|x| x.downcase.to_sym}

  class Point < Hashie::Mash
    def km; super.to_f; end
    def lat; super.to_f; end
    def lon; super.to_f; end
    def mile; km * 0.621371192237334; end
    def visited; ['1', 'YES', 'TRUE'].include? super.upcase; end
  end

  attr_reader :points

  def initialize(f=nil)
    @points = f.nil? ? [] : [].tap do |array|
      CSV.foreach(f, :headers => true, :header_converters => :symbol) do |row|
        array << Point.new(row.to_hash)
      end
    end
  end

  def save(f)
    CSV.open(f, "wb") do |csv|
      csv << INPUT_FIELDS.map{ |field| field.to_s.upcase }
      points.each do |point|
        csv << INPUT_FIELDS.map{ |field| point[field] }
      end
    end
  end
end
