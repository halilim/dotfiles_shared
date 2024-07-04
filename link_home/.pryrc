# frozen_string_literal: true

require Pathname.new(__FILE__).dirname.dirname.join('includes', 'lib', 'ruby_rails', 'ruby_common')

if defined?(PryByebug)
  %w[_b _w where].each { |a| Pry.commands.alias_command(a, 'backtrace') }
  Pry.commands.alias_command('_c', 'continue')
  Pry.commands.alias_command('_f', 'finish')
  Pry.commands.alias_command('_n', 'next')
  Pry.commands.alias_command('_s', 'step')
  Pry.commands.alias_command('_u', 'up')
end

ConsoleExtender.configure_extension('amazing_print') do
  AmazingPrint.pry!
end

ConsoleExtender.configure_extension('hirber') do
  # https://github.com/pry/pry/wiki/FAQ#how-can-i-use-the-hirb-gem-with-pry
  old_print = Pry.config.print
  Pry.config.print = proc do |*args|
    Hirb::View.view_or_page_output(args[1]) || old_print.call(*args)
  end
end
