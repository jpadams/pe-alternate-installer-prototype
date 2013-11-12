module Puppet::Parser::Functions
 newfunction(:hiera_or_undef, :type => :rvalue, :doc => <<-EOS

This function will perform a hiera lookup on the key(s) specified. It will
check each key given sequentially, and return the hiera value found for the
first valid key. If no key given is valid, the undef keyword will be returned.

This allows default values for class parameters to be specified in Puppet 2.7.x
by hiera call, without overriding parameter settings when no key is actually
defined in hiera, allowing the default value to be set to undef.

This function was written due to a desire to use a statement such as the
following in the Puppet DSL, and the inability to do so due to the fact that
when passed to a function the undef keyword is received internally as an empty
string.

    class example (
      $message = hiera('message', undef),
    ) {
      notify { 'title': message => $message; }
    }

This goal is now achieved with the hiera_or_undef function as follows (the
added ability to pass additional parameters to lookup if the first fails is
largely there because it's so easy to implement and could potentially be useful
down the line).

    class example (
      $message = hiera_or_undef('message'),
    ) {
      notify { 'title': message => $message; }
    }

EOS
) do |args|
    args  = args.compact
    value = nil
    args.each do |key|
      begin
        value = function_hiera(key)
        break
      rescue
        next
      end
    end
    return value || :undef
  end
end
