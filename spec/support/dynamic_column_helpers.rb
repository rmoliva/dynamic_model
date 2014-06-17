module DynamicColumnHelpers
  
  # Iterate over a list of types for testing
  # it is posible to define a specific list of types
  # 
  # each_column_datatype do |type| # For all types
  #
  # each_column_datatype('boolean') do |type| # Only for the boolean type
  #
  # each_column_datatype(%w(string boolean)) do |type| # Only the string and boolean
  # 
  def each_column_datatype(type_list = nil)
    type_list ||= DynamicModel::Type::Base.types
    type_list = [type_list] if type_list.is_a?(String)
    
    type_list.each do |type|
      yield(type)
    end
  end
end