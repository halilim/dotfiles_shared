# frozen_string_literal: true

def colorize(text, *colors)
  IRB::Color.colorize(
    text,
    colors.map do |color|
      color.to_s.upcase.to_sym
    end
  )
end

# RubyMine debugger doesn't show the output, so we return it instead
def output?
  $stdout.is_a?(StringIO) || $stdout.echo?
end
