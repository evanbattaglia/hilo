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
  end

  attr_reader :points

  class Range
    attr_reader :start, :stop, :field
    def initialize(start, stop, field)
      @start, @stop, @field = start, stop, field
      raise "Range start doesn't have value!" if value.nil?
    end
    def value
      start[field]
    end
    def start_km
      start.km
    end
    def stop_km
      stop.km
    end
    def length
      stop_km - start_km
    end
  end

  def ranges(field)
    [].tap do |ranges|
      last_point = nil
      points.each do |point|
        if point[field]
          if last_point
            ranges << Range.new(last_point, point, field)
          end
          last_point = point
        end
      end

      # case where last point does not have that field (as it normally wouldn't), count that last segment too
      if last_point && last_point != points.last
        ranges << Range.new(last_point, points.last, field)
      end
    end
  end

  def initialize(f=nil)
    if f.is_a? String
      @filename = f
      f = open(f, "r")
    end
    @points = f.nil? ? [] : [].tap do |array|
      CSV(f, :headers => true, :header_converters => :symbol).each do |row|
        array << Point.new(row.to_hash)
      end
    end
  end

  def save(file=nil)
    file ||= @filename || STDOUT
    file = file.is_a?(String) ? open(file, "wb") : file
    CSV(file) do |csv|
      csv << INPUT_FIELDS.map{ |field| field.to_s.upcase }
      points.each do |point|
        csv << INPUT_FIELDS.map{ |field| point[field] }
      end
    end

    file.close  unless file.is_a?(String)
  end

  def self.reader
    hilo = Hilo.new(ARGV[0] || STDIN)
    hilo.points.each do |p|
      yield p
    end
  end

  def self.filter(insitu = false)
    insitu = ARGV.delete("-i")
    hilo = Hilo.new(ARGV[0] || STDIN)
    hilo.points.each do |p|
      yield p
    end
    if insitu
      hilo.save
    else
      hilo.save(ARGV[1] || STDOUT)
    end
  end
end
