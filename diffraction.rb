require 'date'
require 'open-uri'
require 'json'
require 'cgi'

class Diffraction
  MAX = 240
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
    
    # Break path into quote/year & discard pre and post slashes
    quote, year = CGI.unescape( request.path_info ).
                  gsub(/^\/?([\w\-^\/]+)\/?$/, "\\1").
                  split('/')
    # Create a new Diffraction object, fetch the quotes, and convert to json
    response.body = self.class.new( quote, year ).fetch(:close).to_json
    response['Content-Type'] = 'json'
    response['Content-Length'] = response.body.size.to_s
    response.finish
  end
  
  def fetch key = nil
    # Open a connection to the feed
    open( URL.new( @quote, @year ).to_s ) do |table|
      table.each do |s|
        row = {}
        row[:date], 
        row[:open], 
        row[:high], 
        row[:low], 
        row[:close], 
        row[:volume], 
        row[:adj_close] = s.delete("\n")                  # Delete trailing \n
                           .split(',')                    # Split into array
                           .collect { |s| MAX - s.to_i }  # Convert to ints
        row.shift                                         # Discard the date
        @data << row                                      # Add row to dataset
      end
      @data.shift                                         # Discard first row
    end
    
    # If a key was provided, only return that column.
    # Reverse the array, to get the rows in chronological order.
    # Normalize the rows.
    if key
      normalize @data.collect { |i| i[ key ] }.reverse, MAX
    else
      normalize @data.reverse, MAX
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
    BASE = "http://ichart.finance.yahoo.com/table.csv?" # The base url
    GAP = { day: 'd', week: 'w', month: 'm' } # The frequency of the quotes (daily, monthly...)
    PARAMS = { quote: 's', gap: 'g', month: 'a', day: 'b', year: 'c' } # URL parameter names
    
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
    
    # Construct the URL
    def to_s
      BASE + @url.collect do |k, v|
        PARAMS[ k ] + '=' + CGI.escape( v.to_s ) + '&'
      end.join
    end
  end
end

class String
  alias each each_line
end
