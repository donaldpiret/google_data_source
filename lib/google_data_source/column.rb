module GoogleDataSource
  class Column
    TYPES = {"3" => "number",
             "253" => "string",
             "246" => "number",
             "1" => "boolean",
             "12" => "datetime",
             "8" => "number",
             "10" => "date"}
    
    attr_reader :type, :id, :label, :pattern
    
    def initialize(params)
      @type = params[:type]
      @id = params[:id]
      @label = params[:label]
      @pattern = params[:pattern]
    end
    
    def self.from_result(result)
      fields = result.fetch_fields
      collection = []
      fields.each do |field|
        collection << self.new(:id => field.name,
                               :label => field.name.titleize,
                               :type => TYPES[field.type.to_s])
      end
      collection
    end
    
    def self.from_active_record(model)
      columns = model.columns
      collection = []
      columns.each do |column|
        collection << self.new(:type => self.parse_type(column),
                               :id => column.name,
                               :label => column.human_name)
      end
      return collection
    end
    
    def self.from_resultset(resultset)
      sample_object = resultset.first
      columns = sample_object.attributes.collect {|attribute| sample_object.column_for_attribute(attribute.first) || attribute.first}
      collection = []
      columns.each do |column|
        if column.is_a?(String)
          sample_data = sample_object.send(column) rescue nil
          column_type = self.numeric?(sample_data) ? 'number' : 'string'
          collection << self.new(:type => column_type,
                                 :id => column,
                                 :label => column)
        else
          collection << self.new(:type => self.parse_type(column),
                               :id => column.name,
                               :label => column.human_name)
        end
      end
      return collection
    end
    
    def self.from_query_string(model, query_string, resultset = [])
      column_names = query_string.strip.split(/\s*,\s*/)
      column_names.map! {|column_name|
        column_name.include?(' as ') ? column_name.split(' as ').last : column_name
      }
      columns = model.columns
      collection = []
      column_names.each do |column_name|
        column = columns.select {|model_column| model_column.name == column_name}.first
        if column
          collection << self.new(:type => self.parse_type(column),
                                 :id => column.name,
                                 :label => column.human_name)
        else
          sample_object = resultset.first
          sample_data = sample_object.send(column_name) rescue nil
          column_type = self.numeric?(sample_data) ? 'number' : 'string'
          collection << self.new(:type => column_type,
                                 :id => column_name,
                                 :label => column_name)
        end
      end
      return collection
    end
    
    def self.parse_type(column)
      type_string = column.type.to_s
      type_string = "number" if column.number?
      type_string = "string" if column.text?
      return type_string
    end
    
    def self.numeric?(object)
      true if Float(object) rescue false
    end
    
    def data
      {:type => @type,
       :id => @id,
       :label => @label,
       :pattern => @pattern}
    end
  end
end