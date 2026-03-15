# frozen_string_literal: true

require_relative 'utils'

# Displays a DB style table for a list of ActiveRecord objects, hashes, or arrays. Limits the
# number of columns based on the terminal width. Prioritizes id and columns with data over empty
# columns and timestamps.
#
# Modified from https://gist.github.com/bgreenlee/72234
#
# Alternatives:
# * https://github.com/tj/terminal-table
# * https://github.com/arches/table_print
# * https://github.com/aptinio/text-table
#
# @param items [Array<ActiveRecord::Base, Array, Hash>, ActiveRecord_Relation]
# @param columns [Array<Symbol>] optional list of columns to display
# @param format [:ascii, :markdown] output format, default :ascii
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
#   table [{ id: 1, title: '' }, { id: 2, title: 'Baz' }], format: :markdown
#   =>
#   | id | title |
#   |----|-------|
#   | 1  |       |
#   | 2  | Baz   |
#
# @example
#   table Baz.where(foo: 'bar')
#   =>
#   id│title     │foo│foo_bar│etc  │…
#   ──┼──────────┼───┼───────┼─────┼───
#   1 │Lorem ips.│   │baz    │true │…
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
# @todo Move to forked gist? Or convert to classes and a PR to IRB?
def table(items, *columns, format: :ascii) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
  # Load ActiveRecord to prevent an extra query by first_row
  items = items.load.to_a if items.respond_to?(:load)

  first_row = items[0]

  # Convert everything to an array of hashes
  if first_row.respond_to?(:attributes)
    array_of_hashes = items.map(&:attributes)
    columns.map!(&:to_s)
  elsif first_row.is_a?(Array)
    array_of_hashes = items.map { |arr| (0..(arr.length - 1)).zip(arr).to_h }
  else
    array_of_hashes = items
  end

  first_row = array_of_hashes[0]

  columns = first_row.keys if columns.empty?

  empty_columns = first_row.filter_map { |column, cell| column if cell.to_s.empty? }

  prioritize = lambda do |current_columns, column|
    value = current_columns.delete(column)
    current_columns.unshift(column) if value
  end
  prioritize.call(columns, 'id')

  deprioritize = lambda do |current_columns, column|
    value = current_columns.delete(column)
    current_columns.push(column) if value
  end
  [*empty_columns, 'created_at', 'updated_at'].each { |column| deprioritize.call(columns, column) }

  max_column_widths = columns.to_h { |column| [column, column.to_s.length] }

  header_color = :yellow
  sep_color = :magenta

  case format
  when :ascii
    # https://www.compart.com/en/unicode/block/U+2500
    separators = {
      vertical: '│',
      left: '',
      right: '',
      horizontal: '─',
      cross: '┼'
    }

  when :markdown
    separators = {
      vertical: ' | ',
      left: '| ',
      right: ' |',
      horizontal: '-',
      cross: ' | '
    }

  else
    raise ArgumentError, "Invalid format: #{format}"
  end

  ellipsis = '…'

  # Find the max width for each column; start with the column names themselves

  array_of_hashes.each do |row|
    max_column_widths.each_key do |column|
      width = row[column].to_s.length
      max_column_widths[column] = [width, max_column_widths[column]].max
    end
  end

  calc_max_row_width = lambda do |cur_max_column_widths, add = 0|
    cur_max_column_widths.values.sum +
      (separators[:vertical].length * cur_max_column_widths.size) +
      separators[:left].length +
      separators[:right].length +
      add
  end

  terminal_width = Reline.get_screen_size[1]
  max_row_width = calc_max_row_width.call(max_column_widths)
  terminal_width_exceeded = false

  if max_row_width > terminal_width
    terminal_width_exceeded = true
    # We're going to exceed for sure, add the … column
    ellipsis_column_width = ellipsis.length
    max_row_width += ellipsis_column_width
    while max_row_width > terminal_width && max_column_widths.length > 1
      max_column_widths.delete(max_column_widths.keys.last)
      max_row_width = calc_max_row_width.call(max_column_widths, ellipsis_column_width)
    end
  end

  max_col_i = max_column_widths.length - 1
  generate_row = lambda do |color: nil, &block|
    cells = max_column_widths.map.with_index do |(column, width), i|
      text = block.call(column)

      if i < max_col_i || terminal_width_exceeded || format == :markdown
        text = text.to_s.ljust(width)
      end

      text = colorize(text, color) if color
      text
    end

    if terminal_width_exceeded
      ell = ellipsis
      ell = colorize(ell, color) if color
      cells << ell
    end

    [
      colorize(separators[:left], sep_color),
      cells.join(colorize(separators[:vertical], sep_color)),
      colorize(separators[:right], sep_color)
    ].join
  end

  generate_header_separator = lambda do
    cells = max_column_widths.values.map do |width|
      ''.ljust(width, separators[:horizontal])
    end

    cells << separators[:horizontal] if terminal_width_exceeded

    row = [
      separators[:left],
      cells.join(separators[:cross]),
      separators[:right]
    ].join

    colorize(row, sep_color)
  end

  output = [generate_row.call(color: header_color) { |column| column }]
  output << [generate_header_separator.call]

  array_of_hashes.each do |row|
    output << generate_row.call { |column| row[column] }
  end

  row_count = "(#{array_of_hashes.length} rows in set)\n"
  row_count = colorize(row_count, :cyan)
  output << row_count

  output = output.join("\n")
  if output?
    puts output
  else
    output
  end
end
