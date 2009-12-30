module GoogleDataSource
  class DataDateTime
    def initialize(datetime)
      @datetime = datetime
    end
  
    def to_json(options=nil)
      if @datetime
        "new Date(#{@datetime.year}, #{@datetime.month-1}, #{@datetime.day}, #{@datetime.hour}, #{@datetime.min}, #{@datetime.sec})"
      else
        ""
      end
    end
  end
end