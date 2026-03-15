# frozen_string_literal: true

require_relative 'utils'

# Print methods of an object/class. IRB alternative:
#   ls bar -g baz
#
# @param obj [Object] an instance or class
# @param pattern [Regexp, String] Filter methods by a regular expression
#
# @return [Integer] Number of methods printed
# @return [Array] Method data
#
# @example
#   pm Foo
#   pm bar, /baz/
def pm(obj, pattern = nil) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  methods = obj.methods
  methods = methods.grep(Regexp.new(pattern.to_s, 'i')) if pattern

  data = methods.sort.collect do |name|
    method = obj.method(name)
    if method.arity > 0
      n = method.arity
      args = "(#{(1..n).collect { |i| "arg#{i}" }.join(', ')})"
    elsif method.arity == 0
      args = '()'
    elsif method.arity == -1
      args = '(…)'
    elsif method.arity < -1
      n = -method.arity - 1
      args = "(#{(1..n).collect { |i| "arg#{i}" }.join(', ')}, …)"
    end

    # Remove ActiveRecord attributes
    # Example inspects:
    #   #<Method: FooBar(ActiveRecord::Base)#baz(id: integer, …) …/etc.rb:42>
    #   #<Method: FooBar(ActiveRecord::Base).baz(qux, options=…, &block) …/etc.rb:42>
    #   #<Class:FooBar>(ActiveRecord::Base)
    inspection = method.inspect
    matches = inspection.match %r{ # rubocop:disable Style/RegexpLiteral
      \A\#<(Method|Class):\s*
      (?<class>[^(]+)>?
      (?<attrs>\([^)]+:\s+[^)]*\))?
      (?<base>\([^)]+\))?
      (?<method>\#|\.#{Regexp.escape(name)})?
    }x

    [name.to_s, args, matches ? "#{matches[:class]}#{matches[:base]}" : inspection]
  end

  return data unless output?

  max_name = data.collect { |item| item[0].size }.max
  max_args = data.collect { |item| item[1].size }.max
  data.each do |item|
    print " #{colorize(item[0].to_s.rjust(max_name), :yellow)}"
    print colorize(item[1].ljust(max_args), :blue)
    print "   #{colorize(item[2], :magenta)}\n"
  end

  data.size
end
