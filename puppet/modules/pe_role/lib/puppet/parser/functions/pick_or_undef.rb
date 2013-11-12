module Puppet::Parser::Functions
 newfunction(:pick_or_undef, :type => :rvalue, :doc => <<-EOS

The pick_or_undef function will perform a pick lookup on the key(s) specified.
It will check each key given sequentially, and return the first key pick()ed.
If no key is selected by pick(), pick_or_undef will return the undef keyword.

This difference in behavior between pick() and pick_or_undef() allows
pick_or_undef to be used as the default value for class parameters specified in
Puppet 2.7.x, without overriding parameter settings when no key would otherwise
be matched, thus allowing the default value to fail back to undef.

EOS
) do |args|
    result = :undef
    begin
      result = function_pick(args)
    rescue
      # pick didn't find anything
    end
    return result
  end
end
