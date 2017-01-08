require 'minitest/autorun'

# http://mislav.net/2011/06/ruby-verbose-mode/
unless Kernel.respond_to? :silence_warnings
  module Kernel
    def silence_warnings
      with_warnings(nil) { yield }
    end

    def with_warnings(flag)
      old_verbose = $VERBOSE
      $VERBOSE = flag

      yield
    ensure
      $VERBOSE = old_verbose
    end
  end
end

# Supress warnings generate by Tenjin
silence_warnings do
  require_relative '../lib/gerablog'
end
