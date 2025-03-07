# frozen_string_literal: true

require 'irb'
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

  context 'with ActiveRecord-like objects' do
    let(:items) do
      # Yeah, no, we're not going to require ActiveRecord just for this test
      # rubocop:disable RSpec/VerifiedDoubles
      [
        double(
          attributes: {
            'created_at' => '2021-01-01 00:00:00',
            'updated_at' => '2021-01-01 00:00:01',
            'title' => 'Bar baz qux',
            'id' => 1,
            'long_title' => 'yay'
          }
        ),

        double(
          attributes: {
            'created_at' => '2021-01-02 00:00:00',
            'updated_at' => '2021-01-02 00:00:01',
            'title' => 'Baz',
            'id' => 2,
            'long_title' => 'nay'
          }
        )
      ]
      # rubocop:enable RSpec/VerifiedDoubles
    end

    it 'outputs a table, id first, timestamps last' do
      expect_output(
        <<~OUTPUT
          id│title      │long_title│created_at         │updated_at
          ──┼───────────┼──────────┼───────────────────┼───────────────────
          1 │Bar baz qux│yay       │2021-01-01 00:00:00│2021-01-01 00:00:01
          2 │Baz        │nay       │2021-01-02 00:00:00│2021-01-02 00:00:01
          (2 rows in set)
        OUTPUT
      )
    end

    context 'with limited and symbol cols' do
      let(:cols) { %i[title long_title] }

      it 'outputs a table' do
        expect_output(
          <<~OUTPUT
            title      │long_title
            ───────────┼──────────
            Bar baz qux│yay
            Baz        │nay
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
