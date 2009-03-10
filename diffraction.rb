require 'date'
require 'open-uri'
require 'json'
require 'cgi'

class Diffraction
  def initialize *args
    if args.count > 0      
      @quote = args.first
      @year = args.last
      @data = []
    end
    self
  end
  
  def call env
    request  = Rack::Request.new env
    response = Rack::Response.new
    
    # Break path into discreet parts & trim slashes
    quote, year = CGI.unescape( request.path_info ).
                  gsub( /^\/?([\w\-^\/]+)\/?$/, "\\1").
                  split('/')
    puts "quote:" + quote + " year:" + year
    response.body = self.class.new( quote, year ).fetch(:close).to_json
    response['Content-Type'] = 'json'
    response['Content-Length'] = response.body.size.to_s
    response.finish
  end
  
  def fetch key = nil
    open( URL.new( @quote, @year ).to_str ) do |table|
      table.each do |s|
        row = {}
        row[:date], 
        row[:open], 
        row[:high], 
        row[:low], 
        row[:close], 
        row[:volume], 
        row[:adj_close] = s.delete("\n").           # Delete trailing \n
                            split(',').             # Split into array
                            collect { |s| s.to_i }  # Convert to ints
        row.shift                                   # Discard the date
        @data << row                                # Add row to dataset
      end
      @data.shift                                   # Discard first row
    end
    
    if key
      normalize @data.collect { |i| i[ key ] }.reverse, 256
    else
      normalize @data.reverse, 256
    end
  end
  
  def normalize input, norm
    smallest = largest = nil
    
		# Find largest and smallest numbers
		input.each do |i|
			largest = i if !largest || i > largest
			smallest = i if !smallest || i < smallest
		end
		
		# Normalize
		input.collect do |i|
			( ( i - smallest ) * norm / ( largest - smallest ) ).to_i
		end
  end
  
  class URL    
    BASE = "http://ichart.finance.yahoo.com/table.csv?"
    GAP = { day: 'd', week: 'w', month: 'm' }
    PARAMS = { 
      quote: 's', 
      gap: 'g', 
      month: 'a', 
      day: 'b', 
      year: 'c'
    }
    
    def initialize quote, year = 1986, gap = :day
      @url = { 
        quote: quote,
        month: '1',
        day: '1', 
        year: year, 
        gap: GAP[ gap ] 
      }
      self
    end
    
    def to_str
      BASE + @url.collect do |k, v|
        PARAMS[ k ] + '=' + CGI.escape( v.to_s ) + '&'
      end.join
    end
  end
end

class String
  alias each each_line
end
