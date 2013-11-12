module Puppet::Parser::Functions
  newfunction(:pe_puppetdb_safe_hiera_hash, :type => :rvalue) do |args|
    property = args[0]
    default_value = args[1]

    Puppet::Parser::Functions.function('hiera_hash')

    # if hiera is not configured the default value is used
    begin
      value = function_hiera_hash([property, default_value])
    rescue
      value = default_value
    end

    value
  end
end
