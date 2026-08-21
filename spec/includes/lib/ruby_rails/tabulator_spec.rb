# frozen_string_literal: true

require_relative '../../../../includes/lib/ruby_rails/tabulator'

RSpec.describe Tabulator do
  describe 't' do
    subject(:the_call) { described_class.t(items, *cols, format:) }

    let(:items) { [] }
    let(:cols) { [] }
    let(:format) { :ascii }

    before do
      # Disable colorize
      allow($stdout).to receive(:tty?).and_return(false)
    end

    context 'with an array of hashes' do
      let(:items) do
        [
          { id: 1, title: 'Bar baz qux', long_title: 'yay', another: 'lorem ipsum' },
          { id: 2, title: 'Baz', long_title: 'nay', another: 'dolor' }
        ]
      end
      let(:cols) { %i[id title long_title] }

      shared_examples 'output table' do
        it 'outputs a table' do
          expect(the_call).to eq(
            <<~OUTPUT
              id│title      │long_title
              ──┼───────────┼──────────
              1 │Bar baz qux│yay
              2 │Baz        │nay
              (2 rows in set)
            OUTPUT
          )
        end
      end

      include_examples 'output table'

      context 'without IRB' do
        before do
          allow(Kernel).to receive(:require).with('irb').and_raise(LoadError)
        end

        include_examples 'output table'
      end

      context 'with markdown format' do
        let(:format) { :markdown }

        it 'outputs a table' do
          expect(the_call).to eq(
            <<~OUTPUT
              | id | title       | long_title |
              | -- | ----------- | ---------- |
              | 1  | Bar baz qux | yay        |
              | 2  | Baz         | nay        |
              (2 rows in set)
            OUTPUT
          )
        end
      end

      context 'when the width of the output exceeds the width of the terminal' do
        before do
          allow(Reline).to receive(:get_screen_size).and_return([0, 20])
        end

        it 'truncates' do
          expect(the_call).to eq(<<~OUTPUT)
            id│title      │…
            ──┼───────────┼─
            1 │Bar baz qux│…
            2 │Baz        │…
            (2 rows in set)
          OUTPUT
        end

        context 'with markdown format' do
          let(:format) { :markdown }

          it 'truncates' do
            expect(the_call).to eq(<<~OUTPUT)
              | id | … |
              | -- | - |
              | 1  | … |
              | 2  | … |
              (2 rows in set)
            OUTPUT
          end
        end
      end
    end

    context 'with ActiveRecord' do
      require 'active_record'

      before do
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        ActiveRecord::Schema.verbose = false

        ActiveRecord::Schema.define do
          create_table :things do |t|
            t.string :title
            t.text :desc
            t.timestamps
          end
        end

        stub_const('Thing', Class.new(ActiveRecord::Base) do
          self.table_name = 'things'
        end)

        Thing.create!(id: 1, title: 'Bar baz', desc: 'yay',
                      created_at: '2026-03-30 01:53:55 UTC', updated_at: '2026-03-30 01:54:55 UTC')
        Thing.create!(id: 2, title: 'Baz', desc: 'nay',
                      created_at: '2026-03-30 02:53:55 UTC', updated_at: '2026-03-30 02:54:55 UTC')
      end

      after do
        ActiveRecord::Base.connection.close
      end

      let(:items) { Thing.all }

      it 'outputs a table, id first, timestamps last' do
        expect(the_call).to eq(<<~OUTPUT)
          id│title  │desc│created_at             │updated_at
          ──┼───────┼────┼───────────────────────┼───────────────────────
          1 │Bar baz│yay │2026-03-30 01:53:55 UTC│2026-03-30 01:54:55 UTC
          2 │Baz    │nay │2026-03-30 02:53:55 UTC│2026-03-30 02:54:55 UTC
          (2 rows in set)
        OUTPUT
      end

      context 'with limited and symbol cols' do
        let(:cols) { %i[title desc] }

        it 'outputs a table' do
          expect(the_call).to eq(<<~OUTPUT)
            title  │desc
            ───────┼────
            Bar baz│yay
            Baz    │nay
            (2 rows in set)
          OUTPUT
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
        expect(the_call).to eq(<<~OUTPUT)
          0│1          │2
          ─┼───────────┼───────────
          1│Bar baz qux│yay
          2│Baz        │nay
          3│Foo qux    │lorem ipsum
          (3 rows in set)
        OUTPUT
      end
    end
  end
end
