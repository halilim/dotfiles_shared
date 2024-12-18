# frozen_string_literal: true

require 'pathname'

require Pathname.new(File.readlink(__FILE__)).dirname.dirname
                .join('includes', 'lib', 'ruby_rails', 'ruby_common').to_s

if defined?(PryByebug)
  %w[_b _w where].each { |a| Pry.commands.alias_command(a, 'backtrace') }
  Pry.commands.alias_command('_c', 'continue')
  Pry.commands.alias_command('_f', 'finish')
  Pry.commands.alias_command('_n', 'next')
  Pry.commands.alias_command('_s', 'step')
  Pry.commands.alias_command('_u', 'up')
end
