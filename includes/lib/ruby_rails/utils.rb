# frozen_string_literal: true

def colorize(text, *colors)
  IRB::Color.colorize(
    text,
    colors.map do |color|
      color.to_s.upcase.to_sym
    end
  )
end
