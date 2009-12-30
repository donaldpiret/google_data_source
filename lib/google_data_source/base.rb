module GoogleDataSource
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  ## 
  # Class Methods
  module ClassMethods
    def google_data_source(params, options = {})
      joins = options[:joins]
      result = self.connection.execute(Parser.query_string_to_sql(params[:tq], self, joins))
      cols = Column.from_result(result)
      datasource = GoogleDataSource::Base.from_params(params)
      datasource.set(cols, result)
      return datasource
    end
  end
  
  class Base
    attr_reader :data, :cols, :errors
    
    # Creates a new instance and validates it. 
    # Protected method so it can be used from the subclasses
    def initialize(gdata_params)
      @params = gdata_params
      @errors = {}
      @cols = []
      @data = []
      @version = "0.6"
      @coltypes = [ "boolean", "number", "string", "date", "datetime", "timeofday"]
      @colkeys = [ :type, :id, :label, :pattern]
    
      validate
    end
    protected :initialize
    
    def self.from_params(params)
      # Exract GDataSource params from the request.
      gdata_params = {}
      tqx = params[:tqx]
      unless tqx.blank?
        gdata_params[:tqx] = true
        tqx.split(';').each do |kv|
          key, value = kv.split(':')
          gdata_params[key.to_sym] = value
        end
      end
    
      # Create the appropriate GDataSource instance from the gdata-specific parameters
      gdata_params[:out] ||= "json"    
      gdata = from_gdata_params(gdata_params)
    end
    
    # Factory method to create a GDataSource instance from a serie of valid GData
    # parameters, as described in the official documentation (see above links).
    # 
    # +gdata_params+ can be any map-like object that maps keys (like +:out+, +:reqId+
    # and so forth) to their values. Keys must be symbols.
    def self.from_gdata_params(gdata_params)
      case gdata_params[:out]
      when "json"
        JsonData.new(gdata_params)
      when "html"
        HtmlData.new(gdata_params)
      when "csv"
        CsvData.new(gdata_params)
      else
        InvalidData.new(gdata_params)
      end
    end
    
    # Access a GData parameter. +k+ must be symbols, like +:out+, +:reqId+.
    def [](k)
      @params[k]
    end
  
    # Sets a GData parameter. +k+ must be symbols, like +:out+, +:reqId+.
    # The instance is re-validated afterward.
    def []=(k, v)
      @params[k] = v
      validate
    end
  
    # Checks whether this instance is valid (in terms of configuration parameters)
    # or not.
    def valid?
      @errors.size == 0
    end
  
    # Manually adds a new validation error. +key+ should be a symbol pointing
    # to the invalid parameter or element.
    def add_error(key, message)
      @errors[key] = message
      return self
    end
    
    # Sets the data to be exported. +data+ should be a collection of activerecord object. The 
    # first index should iterate over rows, the second over columns. Column 
    # ordering must be the same used in +add_col+ invokations.
    #
    # Anything that behaves like a 2-dimensional array and supports +each+ is
    # a perfectly fine alternative.
    def set(cols, data)
      cols.each do |col|
        raise ArgumentError, "Invalid column type: #{col.type}" if !@coltypes.include?(col.type)
        @cols << col.data
      end
      # @data should be a 2-dimensional array
      @data = []
      data.each do |record|
        @data << record
      end
      #data
      return self
    end
    
    # Validates this instance by checking that the configuration parameters
    # conform to the official specs.
    def validate
      @errors.clear
      if @params[:tqx]
        add_error(:reqId, "Missing required parameter reqId") unless @params[:reqId]
      
        if @params[:version] && @params[:version] != @version
          add_error(:version, "Unsupported version #{@params[:version]}")
        end
      end
    end
  
    # Empty method. This is a placeholder implemented by subclasses that
    # produce the response according to a given format.
    def response
    end
    
    # Empty method. This is a placeholder implemented by subclasses that return the correct format
    def format
    end
    
  end
end