# frozen_string_literal: true

# TODO: Add/integrate/replace with https://github.com/janlelis/irbtools

require Pathname.new(File.readlink(__FILE__)).dirname.dirname.join('includes', 'lib', 'ruby_rails', 'ruby_common')

IRB.conf[:SAVE_HISTORY] = 10_000

# TODO: https://github.com/ruby/irb/blob/master/EXTEND_IRB.md (if available)
ConsoleExtender.configure_extension('amazing_print') do
  AmazingPrint.irb!
end
