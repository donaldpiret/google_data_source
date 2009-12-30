module GoogleDataSource
  class DataDate
    def initialize(date)
      @date = date
    end
  
    def to_json(options=nil)
      if @date
        "new Date(#{@date.year}, #{@date.month-1}, #{@date.day})"
      else
        ""
      end
    end
  end
end