module GoogleDataSource
  module Parser
    def self.query_string_to_sql(query_string, model, joins = nil)
      options = self.parse_query_string(query_string)
      sql = "SELECT #{options[:select] || '*'} "
      sql << "FROM #{model.to_s.tableize} "
      sql << "#{joins} " if joins 
      sql << "WHERE #{options[:conditions]} " if options[:conditions]
      sql << "GROUP BY #{options[:group]} " if options[:group]
      sql << "ORDER BY #{options[:order]}" if options[:order]
      sql << "LIMIT #{options[:limit]} " if options[:limit]
      sql << "OFFSET #{options[:offset]}" if options[:offset]
      sql
    end
    
    def self.parse_query_string(query_string)
      # You need to parse a query string and build a correct activerecord query based on this
      query_string.try(:downcase!)
      options = {}
      unless query_string.blank?
        # Parse the select column
        select_regexp = Regexp.new(/(?:^| )select (.*?)((where|group\sby|order\sby|limit|offset).*)?$/i)
        select_columns = select_regexp.match(query_string)[1] rescue nil #.split(/[, ]+/) rescue []
        # Parse the where column
        where_regexp = Regexp.new(/(?:^| )where (.*?)((select|group\sby|order\sby|limit|offset).*)?$/i)
        where_conditions = where_regexp.match(query_string)[1] rescue nil
        # Parse the group column
        group_regexp = Regexp.new(/(?:^| )group\sby (.*?)((select|where|order\sby|limit|offset).*)?$/i)
        group_columns = group_regexp.match(query_string)[1] rescue nil
        # Parse the order column
        order_regexp = Regexp.new(/(?:^| )order\sby (.*?)((select|where|group\sby|limit|offset).*)?$/i)
        order_columns = order_regexp.match(query_string)[1] rescue nil
        # Parse the limit clause
        limit_regexp = Regexp.new(/(?:^| )limit (.*?)((select|where|group\sby|order\sby|offset).*)?$/i)
        limit_count = limit_regexp.match(query_string)[1] rescue nil
        # Pare the offset clause
        offset_regexp = Regexp.new(/(?:^| )offset (.*?)((select|where|group\sby|order\sby|limit).*)?$/i)
        offset_count = offset_regexp.match(query_string)[1] rescue nil
      end

      options[:select] = select_columns || '*'
      options[:conditions] = where_conditions unless where_conditions.blank?
      options[:group] = group_columns unless group_columns.blank?
      options[:order] = order_columns unless order_columns.blank?
      options[:limit] = limit_count unless limit_count.blank?
      options[:offset] = offset_count unless offset_count.blank?
      return options
    end
  end
end