require 'csv'

module GoogleDataSource
  class CsvData < Base
    def response
      rsp = []
      CSV::Writer.generate(rsp) do |csv|
        csv << cols.map { |col| col[:label] || col[:id] || col[:type] }
        data.each do |datarow|
          csv << datarow
        end
      end
      return rsp.join
    end
  end
end