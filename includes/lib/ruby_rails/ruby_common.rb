# frozen_string_literal: true

require 'irb/color'
require 'io/console'
require 'stringio'

# RubyMine debugger doesn't load .irbrc/.pryrc. Add live template `lrc`:
# (live templates are available in the interactive console)
# load File.join(ENV['DOTFILES_INCLUDES'], 'lib', 'ruby_rails', 'ruby_common.rb')

# rubocop:disable Style/NumericPredicate

# Displays a DB style table for a list of ActiveRecord objects, hashes, or arrays. Limits the
# number of columns based on the terminal width. Prioritizes id and columns with data over empty
# columns and timestamps.
#
# Modified from https://gist.github.com/bgreenlee/72234
#
# Alternatives:
# - https://github.com/tj/terminal-table
# - https://github.com/arches/table_print
# - https://github.com/aptinio/text-table
#
# @param items [Array<ActiveRecord::Base, Array, Hash>, ActiveRecord_Relation]
# @param cols [Array<Symbol>] optional list of columns to display
#
# @example
#   table [{ id: 1, title: 'Bar', qux: 'yay' }, { id: 2, title: 'Baz', qux: 'nay' }], :id, :title
#   =>
#   id│title
#   ──┼─────
#   1 │Bar
#   2 │Baz
#
# @example
#   table Baz.where(foo: 'bar')
#   =>
#   id│title     │foo│foo_bar│etc  │…
#   ──┼──────────┼───┼───────┼─────┼───
#   1 │Lorem ips.│bar│baz    │true │…
#   2 │Dolor     │bar│qux    │false│…
#
# @example
#   table [[2, :foo], [4, :bar]]
#   =>
#   0│1
#   ─┼───
#   2│foo
#   4│bar
#
# @todo Move to a forked gist?
def table(items, *cols) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  # Load ActiveRecord to prevent extra query by first_item
  items = items.load.to_a if items.respond_to?(:load)

  first_item = items[0]

  # Convert everything to an array of hashes
  if first_item.respond_to?(:attributes)
    items.map!(&:attributes)
    cols.map!(&:to_s)
  elsif first_item.is_a?(Array)
    items.map! { |arr| (0..arr.length - 1).zip(arr).to_h }
  end

  first_item = items[0]

  cols = first_item.keys if cols.empty?

  empty_cols = first_item.filter_map { |k, v| k if v.to_s.empty? }

  prioritize = lambda do |cur_cols, col|
    val = cur_cols.delete(col)
    cur_cols.unshift(col) if val
  end
  prioritize.call(cols, 'id')

  deprioritize = lambda do |cur_cols, col|
    val = cur_cols.delete(col)
    cur_cols.push(col) if val
  end
  [*empty_cols, 'created_at', 'updated_at'].each { |col| deprioritize.call(cols, col) }

  col2len = cols.to_h { |col| [col, col.to_s.length] }

  title_color = :yellow
  border_color = :magenta
  # https://www.compart.com/en/unicode/block/U+2500
  b_v = color('│', border_color)
  b_h = '─'
  b_vh = '┼'
  ellipsis = '…'

  # Find max length for each column; start with the column names themselves

  items.each do |item|
    col2len.each_key do |col|
      len = item[col].to_s.length
      col2len[col] = [len, col2len[col]].max
    end
  end

  calc_max_row_len = ->(cur_col2len, add = 0) { cur_col2len.values.sum + cur_col2len.length + add }

  terminal_width = Reline.get_screen_size[1]
  max_row_len = calc_max_row_len.call(col2len)
  terminal_width_exceeded = false

  if max_row_len > terminal_width
    terminal_width_exceeded = true
    # We're going to exceed for sure, add the … column
    dot_col_len = ellipsis.length
    max_row_len += dot_col_len
    while max_row_len > terminal_width && col2len.length > 1
      col2len.delete(col2len.keys.last)
      max_row_len = calc_max_row_len.call(col2len, dot_col_len)
    end
  end

  max_col_i = col2len.length - 1
  gen_row = lambda do |color: nil, &block|
    cells = col2len.map.with_index do |(k, len), i|
      text = block.call(k)
      text = format("%-#{len}s", text) if i < max_col_i || terminal_width_exceeded
      color(text, color) if color
      text
    end

    if terminal_width_exceeded
      ell = ellipsis
      ell = color(ell, color) if color
      cells << ell
    end

    cells.join(b_v)
  end

  outputs = [gen_row.call(color: title_color) { |k| k }]

  border = col2len.values.map { |len| b_h * len }.join(b_vh)
  border << b_vh << b_h if terminal_width_exceeded
  outputs << color(border, border_color)

  items.each do |item|
    outputs << (gen_row.call { |k| item[k] })
  end

  outputs << color("(#{items.length} rows in set)\n", :cyan)

  output = outputs.join("\n")
  if output?
    puts output
  else
    output
  end
end

alias art table
alias tbl table

# Print methods of an object/class. IRB alternative:
#   ls bar -g baz
#
# @param obj [Object] an instance or class
# @param pattern [Regexp, String] Filter methods by a regular expression
#
# @return [Integer] number of methods printed
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
    print " #{color(item[0].to_s.rjust(max_name), :yellow)}"
    print color(item[1].ljust(max_args), :blue)
    print "   #{color(item[2], :magenta)}\n"
  end

  data.size
end

# Print hash key-value pairs whose keys match a regular expression
#
# @param hash [Hash]
# @param pattern [Regexp, String]
def pk(hash, pattern)
  hash.select { |k, _v| k.to_s =~ Regexp.new(pattern.to_s, 'i') }
end

# Print hash key-value pairs whose values match a regular expression
#
# @param hash [Hash]
# @param pattern [Regexp, String]
def pv(hash, pattern)
  hash.select { |_k, v| v.to_s =~ Regexp.new(pattern.to_s, 'i') }
end

if defined?(reload!)
  # `alias_method :r!, :reload!` doesn't work because #alias_method is defined on `Module`,
  #   not on `Object`, which is the context here.
  def r!
    reload!
  end
end

def color(text, *color)
  IRB::Color.colorize(text, color.map { |c| c.to_s.upcase.to_sym })
end

# RubyMine debugger doesn't show the output, so we return it instead
def output?
  $stdout.is_a?(StringIO) || $stdout.echo?
end

# rubocop:enable Style/NumericPredicate
