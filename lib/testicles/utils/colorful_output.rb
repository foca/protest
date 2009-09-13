module Testicles
  module Utils
    # Mixin that provides colorful output to your console based reports. This uses
    # bash's escape sequences, so it won't work on windows.
    #
    # TODO: Make this work on windows with ansicolor or whatever the gem is named
    module ColorfulOutput
      # Returns a hash with the color values for different states. Override this
      # method safely to change the output colors. The defaults are:
      #
      # :passed::  Light green
      # :pending:: Light yellow
      # :errored:: Light purple
      # :failed::  Light red
      #
      # See http://www.hypexr.org/bash_tutorial.php#colors for a description of
      # Bash color codes.
      def self.colors
        { :passed => "1;32",
          :pending => "1;33",
          :errored => "1;35",
          :failed => "1;31" }
      end

      class << self
        # Whether to use colors in the output or not. The default is +true+.
        attr_accessor :colorize
      end

      self.colorize = true

      # Print the string followed by a newline to whatever IO stream is defined in
      # the method #stream using the correct color depending on the state passed.
      def puts(string=nil, state=:normal)
        if string.nil? # calling IO#puts with nil is not the same as with no args
          stream.puts
        else
          stream.puts colorize(string, state)
        end
      end

      # Print the string to whatever IO stream is defined in the method #stream
      # using the correct color depending on the state passed.
      def print(string=nil, state=:normal)
        if string.nil? # calling IO#puts with nil is not the same as with no args
          stream.print
        else
          stream.print colorize(string, state)
        end
      end

      private

        def colorize(string, state)
          if state == :normal || !ColorfulOutput.colorize
            string
          else
            "\033[#{color_for_state(state)}m#{string}\033[0m"
          end
        end

        def color_for_state(state)
          ColorfulOutput.colors.fetch(state)
        end
    end
  end
end
