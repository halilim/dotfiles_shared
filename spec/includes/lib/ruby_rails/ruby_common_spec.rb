# frozen_string_literal: true

require 'irb'

ENV.delete('DOTFILES_CUSTOM')
require_relative '../../../../includes/lib/ruby_rails/ruby_common'

RSpec.describe '.table' do # rubocop:disable RSpec/DescribeClass
  subject(:call_table) { table(items, *cols) }

  let(:items) { [] }
  let(:cols) { [] }

  def expect_output(expected)
    expect { call_table }.to output(expected).to_stdout
  end

  context 'with an array of hashes' do
    let(:items) do
      [
        { id: 1, title: 'Bar baz qux', long_title: 'yay', another: 'lorem ipsum' },
        { id: 2, title: 'Baz', long_title: 'nay', another: 'dolor' }
      ]
    end
    let(:cols) { %i[id title long_title] }

    it 'outputs a table' do
      expect_output(
        <<~OUTPUT
          id│title      │long_title
          ──┼───────────┼──────────
          1 │Bar baz qux│yay
          2 │Baz        │nay
          (2 rows in set)
        OUTPUT
      )
    end

    context 'when the terminal width is too small' do
      before do
        allow(Reline).to receive(:get_screen_size).and_return([0, 20])
      end

      it 'truncates the rows' do
        expect_output(
          <<~OUTPUT
            id│title      │…
            ──┼───────────┼─
            1 │Bar baz qux│…
            2 │Baz        │…
            (2 rows in set)
          OUTPUT
        )
      end
    end
  end

  # NOTE: Long lines are truncated in Termux
  context 'with ActiveRecord-like objects' do
    let(:items) do
      # Yeah, no, we're not going to require ActiveRecord just for this test
      [
        double(
          attributes: {
            'created_at' => '2021-01-01',
            'updated_at' => '2021-01-02',
            'title' => 'Bar baz',
            'id' => 1,
            'desc' => 'yay'
          }
        ),

        double(
          attributes: {
            'created_at' => '2021-01-03',
            'updated_at' => '2021-01-04',
            'title' => 'Baz',
            'id' => 2,
            'desc' => 'nay'
          }
        )
      ]
    end

    it 'outputs a table, id first, timestamps last' do
      expect_output(
        <<~OUTPUT
          id│title  │desc│created_at│updated_at
          ──┼───────┼────┼──────────┼──────────
          1 │Bar baz│yay │2021-01-01│2021-01-02
          2 │Baz    │nay │2021-01-03│2021-01-04
          (2 rows in set)
        OUTPUT
      )
    end

    context 'with limited and symbol cols' do
      let(:cols) { %i[title desc] }

      it 'outputs a table' do
        expect_output(
          <<~OUTPUT
            title  │desc
            ───────┼────
            Bar baz│yay
            Baz    │nay
            (2 rows in set)
          OUTPUT
        )
      end
    end
  end

  context 'with an array of arrays' do
    let(:items) do
      [
        [1, 'Bar baz qux', 'yay'],
        [2, 'Baz', 'nay'],
        [3, 'Foo qux', 'lorem ipsum']
      ]
    end

    it 'outputs a table' do
      expect_output(
        <<~OUTPUT
          0│1          │2
          ─┼───────────┼───────────
          1│Bar baz qux│yay
          2│Baz        │nay
          3│Foo qux    │lorem ipsum
          (3 rows in set)
        OUTPUT
      )
    end
  end
end
