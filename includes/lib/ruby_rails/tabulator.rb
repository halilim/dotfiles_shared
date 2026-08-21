# frozen_string_literal: true

begin
  # Not a default gem as of Ruby 4
  require 'irb'
rescue LoadError
  module ::IRB
    class Color
      def self.colorize(text, _colors)
        text
      end
    end
  end
end

# reline is not a default gem either, but Both IRB and Pry require it
require 'reline'

# Displays a DB style table for a list of ActiveRecord objects, hashes, or arrays. Limits the
# number of columns based on the terminal width. Prioritizes id and columns with data over empty
# columns and timestamps.
#
# Modified from https://gist.github.com/bgreenlee/72234
#
# Alternatives/inspirations:
# * https://github.com/tj/terminal-table
# * https://github.com/arches/table_print
# * https://github.com/aptinio/text-table
#
# @todo Contribute to IRB?
class Tabulator # rubocop:disable Metrics/ClassLength
  SEPARATORS = {
    # https://www.compart.com/en/unicode/block/U+2500
    ascii: {
      vertical: '│',
      left: '',
      right: '',
      horizontal: '─',
      cross: '┼'
    },

    markdown: {
      vertical: ' | ',
      left: '| ',
      right: ' |',
      horizontal: '-',
      cross: ' | '
    }
  }.freeze

  HIGH_PRIORITY_COLUMNS = %i[id].freeze
  LOW_PRIORITY_COLUMNS = %i[created_at updated_at].freeze

  HEADER_COLOR = :YELLOW
  SEP_COLOR = :MAGENTA
  COUNT_COLOR = :CYAN

  ELLIPSIS = '…'
  ELLIPSIS_LENGTH = ELLIPSIS.length

  COLLECTION_ADAPTERS = {
    'ActiveRecord::Relation' => lambda do |collection|
      # Load to prevent an extra query by first_row
      collection.load.to_a.map do |instance|
        instance.attributes.transform_keys(&:to_sym)
      end
    end
  }.freeze

  ITEM_ADAPTERS = {
    'Array' => lambda do |items|
      items.map do |arr|
        (0..(arr.length - 1)).zip(arr).to_h
      end
    end
  }.freeze

  # @param items [Array<ActiveRecord::Base, Array, Hash>, ActiveRecord::Relation]
  # @param columns [Array<Symbol>] optional list of columns to display
  # @param format [:ascii, :markdown] output format, default :ascii
  #
  # @example
  #   Tabulator.t [{ id: 1, title: 'Bar', qux: 'yay' },
  #                { id: 2, title: 'Baz', qux: 'nay' }], :id, :title
  #   =>
  #   id│title
  #   ──┼─────
  #   1 │Bar
  #   2 │Baz
  #   (2 rows in set)
  #
  # @example
  #   Tabulator.t [{ id: 1, title: '' }, { id: 2, title: 'Baz' }], format: :markdown
  #   =>
  #   | id | title |
  #   |----|-------|
  #   | 1  |       |
  #   | 2  | Baz   |
  #
  # @example
  #   Tabulator.t Baz.where(foo: 'bar')
  #   =>
  #   id│title     │foo│foo_bar│etc  │…
  #   ──┼──────────┼───┼───────┼─────┼───
  #   1 │Lorem ips.│   │baz    │true │…
  #   2 │Dolor     │bar│qux    │false│…
  #
  # @example
  #   Tabulator.t [[2, :foo], [4, :bar]]
  #   =>
  #   0│1
  #   ─┼───
  #   2│foo
  #   4│bar
  def self.t(items, *columns, format: :ascii)
    instance = new(items:, columns:, format:)
    instance.t
  end

  def initialize(items:, columns: [], format: :ascii)
    raise ArgumentError, "Unknown format: #{format}" unless SEPARATORS.key?(format)

    @items = items
    @columns = columns
    @format = format
    @separators = SEPARATORS[format]
  end

  def t # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    array_of_items = fetch_collection(items)
    array_of_hashes = fetch_items(array_of_items)
    @first_row = array_of_hashes[0]

    calculate_columns
    calculate_max_column_widths(array_of_hashes)

    rows = [generate_row(cell_color: HEADER_COLOR) { |column| column }]
    rows << [generate_header_separator]

    array_of_hashes.each do |row|
      rows << generate_row { |column| row[column] }
    end

    count_row = "(#{array_of_hashes.length} rows in set)\n"
    count_row = with_color(count_row, COUNT_COLOR)
    rows << count_row

    rows.join("\n")
  end

  private

  attr_reader :items, :columns, :format,
              :first_row, :separators, :max_column_widths, :terminal_width_exceeded

  def fetch_collection(items)
    return items if items.is_a?(Array)

    _, adapter = COLLECTION_ADAPTERS.find { |klass, _| items.class.name == klass } # rubocop:disable Style/ClassEqualityComparison
    raise ArgumentError, "Unsupported collection type: #{items.class}" unless adapter

    adapter.call(items)
  end

  def fetch_items(array)
    first_item = array[0]
    return array if first_item.is_a?(Hash)

    _, adapter = ITEM_ADAPTERS.find { |klass, _| first_item.class.name == klass } # rubocop:disable Style/ClassEqualityComparison
    raise ArgumentError, "Unsupported item type: #{first_item.class}" unless adapter

    adapter.call(array)
  end

  def calculate_columns
    @columns = first_row.keys if columns.empty?
    prioritize_columns
    deprioritize_columns
  end

  def prioritize_columns
    HIGH_PRIORITY_COLUMNS.each do |column|
      value = columns.delete(column)
      columns.unshift(column) if value
    end
  end

  def deprioritize_columns
    empty_columns = first_row.filter_map { |column, cell| column if cell.to_s.empty? }
    [*empty_columns, *LOW_PRIORITY_COLUMNS].each do |column|
      # @columns = deprioritize(columns, column)
      value = columns.delete(column)
      columns.push(column) if value
    end
  end

  # Find the max width for each column; start with the headers (column names)
  def calculate_max_column_widths(array_of_hashes) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    max_column_widths = columns.to_h { |column| [column, column.to_s.length] }

    array_of_hashes.each do |row|
      max_column_widths.each_key do |column|
        width = row[column].to_s.length
        max_column_widths[column] = [width, max_column_widths[column]].max
      end
    end

    terminal_width = Reline.get_screen_size[1]
    current_width = calc_max_row_width(max_column_widths.values)
    @terminal_width_exceeded = false

    if current_width > terminal_width
      @terminal_width_exceeded = true
      # We're going to exceed for sure, add the … column
      current_width += ELLIPSIS_LENGTH
      while current_width > terminal_width && max_column_widths.length > 1
        max_column_widths.delete(max_column_widths.keys.last)
        current_width = calc_max_row_width(max_column_widths.values, ELLIPSIS_LENGTH)
      end
    end

    @max_column_widths = max_column_widths
  end

  def calc_max_row_width(column_widths, add = 0)
    column_widths.sum +
      (separators[:vertical].length * column_widths.size) +
      separators[:left].length +
      separators[:right].length +
      add
  end

  def generate_row(cell_color: nil) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    max_col_i = max_column_widths.length - 1

    cells = max_column_widths.map.with_index do |(column, width), i|
      text = yield(column)

      if i < max_col_i || terminal_width_exceeded || format == :markdown
        text = text.to_s.ljust(width)
      end

      text = with_color(text, cell_color)
      text
    end

    cells << with_color(ELLIPSIS, cell_color) if terminal_width_exceeded

    [
      with_color(separators[:left], SEP_COLOR),
      cells.join(with_color(separators[:vertical], SEP_COLOR)),
      with_color(separators[:right], SEP_COLOR)
    ].join
  end

  def generate_header_separator # rubocop:disable Metrics/AbcSize
    cells = max_column_widths.values.map do |width|
      ''.ljust(width, separators[:horizontal])
    end

    cells << separators[:horizontal] if terminal_width_exceeded

    row = [
      separators[:left],
      cells.join(separators[:cross]),
      separators[:right]
    ].join

    with_color(row, SEP_COLOR)
  end

  def with_color(text, color)
    return text unless color

    IRB::Color.colorize(text, [color])
  end
end
