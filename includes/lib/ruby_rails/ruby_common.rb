# frozen_string_literal: true

require 'irb/color'
require 'io/console'
require 'stringio'

custom_dotfiles = ENV.fetch('DOTFILES_CUSTOM', nil)
if custom_dotfiles
  custom_file = File.join(custom_dotfiles, 'includes', 'lib', 'ruby_rails', 'ruby_custom.rb')
  load(custom_file) if File.exist?(custom_file)
end

# RubyMine debugger doesn't load .irbrc/.pryrc. Add live template `lrc`:
# (live templates are available in the interactive console)
# load File.join(ENV['DOTFILES_INCLUDES'], 'lib', 'ruby_rails', 'ruby_common.rb')

require_relative 'table'
alias art table
alias tbl table
def markdown_table(items, *cols)
  table(items, *cols, format: :markdown)
end
alias mart markdown_table

require_relative 'pm'

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
