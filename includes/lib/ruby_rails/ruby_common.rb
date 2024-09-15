# frozen_string_literal: true

# rubocop:disable Style/NumericPredicate

# Displays a MySQL-style table for ActiveRecord objects. Limits the number of columns based on the
# terminal width. Prioritizes columns with data over empty columns.
#
# Modified from https://gist.github.com/bgreenlee/72234
#
# @param items [Array<ActiveRecord::Base>, ActiveRecord_Relation] an array/scope of
#   ActiveRecord objects
# @param given_fields [Array<Symbol>] optional list of fields to display
#
# @example
#   art Foo.all, :id, :title
#   =>
#   +----+-------+
#   | id | title |
#   +----+-------+
#   | 1  | Bar   |
#   | 2  | Baz   |
#   +----+-------+
#
# @example
#   art Baz.where(foo: 'bar')
#   =>
#   +----+-------+-------+-------+-------+-----+
#   | id | title | foo   | bar   | etc   | ... |
#   +----+-------+-------+-------+-------+-----+
#   | 1  | Bar   | bar   | baz   | true  | ... |
#   | 2  | Baz   | bar   | qux   | false | ... |
#   +----+-------+-------+-------+-------+-----+
#
# @todo Move to a forked gist?
def ar_table(items, *given_fields) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  cur_fields = given_fields.dup

  # find max length for each field; start with the field names themselves
  cur_fields = items.first.class.column_names if cur_fields.empty?
  cur_max_len = Hash[*cur_fields.map { |f| [f, f.to_s.length] }.flatten]
  items.each do |item|
    cur_fields.each do |field|
      len = item.read_attribute(field).to_s.length
      cur_max_len[field] = len if len > cur_max_len[field]
    end
  end

  calc_max_row_len = ->(max_len, fields, add = 0) { max_len.values.sum + fields.length * 3 + 1 + add }

  term_width = Readline.get_screen_size[1] # or Rake.application.terminal_width
  max_row_len = calc_max_row_len.call(cur_max_len, cur_fields)
  term_width_exceeded = false

  if max_row_len > term_width
    term_width_exceeded = true
    # We're going to exceed for sure, add the ... column
    dot_col_len = 6
    max_row_len += dot_col_len

    first_item = items.first
    comparator = ->(f) { first_item.read_attribute(f).to_s.length.positive? }
    cur_fields.sort! do |a, b|
      # TODO: De-prioritize timestamps, etc. too and add to the method documentation
      a_present = comparator.call(a)
      b_present = comparator.call(b)
      if a_present == b_present
        0
      elsif a_present
        -1
      else
        1
      end
    end

    while max_row_len > term_width && cur_fields.length > 1
      popped_field = cur_fields.pop
      cur_max_len.delete(popped_field)
      max_row_len = calc_max_row_len.call(cur_max_len, cur_fields, dot_col_len)
    end
  end

  # rubocop:disable Style/StringConcatenation
  border = '+-' + cur_fields.map { |f| '-' * cur_max_len[f] }.join('-+-') + '-+'
  border << '-----+' if term_width_exceeded
  title_row = '| ' + cur_fields.map { |f| format("%-#{cur_max_len[f]}s", f.to_s) }.join(' | ') + ' |'
  title_row << ' ... |' if term_width_exceeded

  puts border
  puts title_row
  puts border

  items.each do |item|
    row = '| ' + cur_fields.map { |f| format("%-#{cur_max_len[f]}s", item.read_attribute(f)) }.join(' | ') + ' |'
    row << ' ... |' if term_width_exceeded
    puts row
  end
  # rubocop:enable Style/StringConcatenation

  puts border
  puts "#{items.length} rows in set\n"
end

alias art ar_table

# Print methods of an object/class. IRB alternative:
#   ls bar -g baz
#
# @param obj [Object] an instance or class
# @param options [Array<Regexp, Symbol>] <code>Regexp</code>: filter methods by a regular
#   expression. <code>:more</code>: include methods from Object
#
# @return [Integer] number of methods printed
#
# @example
#   pm Foo
#   pm bar, /baz/
#   pm baz, /qux/, :more
def pm(obj, *options) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  methods = obj.methods
  methods -= Object.methods unless options.include?(:more)

  filter = options.select { |opt| opt.is_a?(Regexp) }.first
  methods = methods.grep(filter) if filter

  data = methods.sort.collect do |name|
    method = obj.method(name)
    if method.arity > 0
      n = method.arity
      args = "(#{(1..n).collect { |i| "arg#{i}" }.join(', ')})"
    elsif method.arity == 0
      args = '()'
    elsif method.arity == -1
      args = '(...)'
    elsif method.arity < -1
      n = -method.arity - 1
      args = "(#{(1..n).collect { |i| "arg#{i}" }.join(', ')}, ...)"
    end

    # Remove ActiveRecord attributes
    # Example inspects:
    #   #<Method: FooBar(ActiveRecord::Base)#baz(id: integer, ...) .../etc.rb:42>
    #   #<Method: FooBar(ActiveRecord::Base).baz(qux, options=..., &block) .../etc.rb:42>
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

  max_name = data.collect { |item| item[0].size }.max
  max_args = data.collect { |item| item[1].size }.max
  data.each do |item|
    print " #{IRB::Color.colorize(item[0].to_s.rjust(max_name), [:YELLOW])}"
    print IRB::Color.colorize(item[1].ljust(max_args), [:BLUE])
    print "   #{IRB::Color.colorize(item[2], [:MAGENTA])}\n"
  end

  data.size
end

# `alias_method :r!, :reload!` doesn't work because #alias_method is defined on `Module`,
#   not on `Object`, which is the context here.
def r!
  reload!
end

# rubocop:enable Style/NumericPredicate
