module GoogleDataSource
  class InvalidData
    def initialize(gviz_params)
      super(gviz_params)
      add_error(:out, "Invalid output format: #{gviz_params[:out]}. Valid ones are json,csv,html")
    end
  end
end