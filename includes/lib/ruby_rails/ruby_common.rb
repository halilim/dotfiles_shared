# frozen_string_literal: true

require 'irb'

def ansi_color(text, color)
  IRB::Color.colorize(text, [color])
end

# Useful methods

# list methods which aren't in superclass
def local_methods(obj = self)
  (obj.methods - obj.class.superclass.instance_methods).sort
end

# Print methods of an object
# Put this before ConsoleExtender to properly report it as loaded
def pm(obj, *options) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
  methods = obj.methods
  methods -= Object.methods unless options.include? :more
  filter = options.select { |opt| opt.is_a?(Regexp) }.first
  methods = methods.select { |name| name =~ filter } if filter # rubocop:disable Style/SelectByRegexp

  data = methods.sort.collect do |name|
    method = obj.method(name)
    if method.arity == 0
      args = '()'
    elsif method.arity > 0
      n = method.arity
      args = "(#{(1..n).collect { |i| "arg#{i}" }.join(', ')})"
    elsif method.arity < 0
      n = -method.arity
      args = "(#{(1..n).collect { |i| "arg#{i}" }.join(', ')}, ...)"
    end
    klass = Regexp.last_match(1) if method.inspect =~ /Method: (.*?)#/
    [name.to_s, args, klass]
  end
  max_name = data.collect { |item| item[0].size }.max
  max_args = data.collect { |item| item[1].size }.max
  data.each do |item|
    print " #{ansi_color(item[0].to_s.rjust(max_name), :YELLOW)}"
    print ansi_color(item[1].ljust(max_args), :BLUE)
    print "   #{ansi_color(item[2], :GRAY)}\n"
  end
  data.size
end

# `alias_method :r!, :reload!` doesn't work because #alias_method is defined on `Module`,
#   not on `Object`, which is the context here.
def r!
  reload!
end

def copy(str)
  IO.popen('pbcopy', 'w') { |f| f << str.to_s }
end

def copy_history
  history = Readline::HISTORY.entries
  index = history.rindex('exit') || -1
  content = history[(index + 1)..-2].join("\n")
  puts content
  copy(content)
end

def paste
  `pbpaste`
end

alias q exit

class ConsoleExtender # :nodoc:
  class << self
    def load_extensions(new_extensions)
      new_extensions.each do |extension_name|
        next if extensions.key?(extension_name)

        if extension_name.include?('()')
          load_method(extension_name)
        else
          load_gem(extension_name)
        end
      end
    end

    def configure_extension(name)
      unless extensions.dig(name, :loaded)
        # log_error("Configure: Extension #{name} not loaded", uplevel: 1)
        return
      end

      yield
    end

    def extensions
      @extensions ||= {}
    end

    private

    def load_method(name)
      bare_name = name.tr('()', '')
      result = TOPLEVEL_BINDING.class.private_method_defined?(bare_name)
      add_result(name, result)
    end

    def load_gem(name)
      lib_path = gem_lib_path(name)
      unless lib_path
        err = "No path for the gem #{name}"
        log_error(err)
        return add_result(name, false, error: err)
      end

      $LOAD_PATH << lib_path unless $LOAD_PATH.include?(lib_path)

      require name
      add_result(name, true)
    rescue LoadError => e
      err = "LoadError for #{name}: #{e.message}"
      log_error(err)
      add_result(name, false, error: err)
    end

    def gem_lib_path(name)
      # TODO: Add asdf support
      pattern = File.join(
        Dir.home,
        ".rbenv/versions/#{RUBY_VERSION}/lib/ruby/gems/*/gems/#{name}*/lib"
      )
      paths = Dir.glob(pattern)
      paths.last
    end

    def add_result(name, result, additional = {})
      extensions[name] = { loaded: result }.merge(additional)
    end

    def log_error(msg, uplevel: 0)
      return unless ENV['VERBOSE']

      Kernel.warn(msg, uplevel: uplevel + 1)
    end
  end
end

# TODO: https://github.com/blackwinter/brice - maybe one day, kinda continuation of wirble
# table_print (& config below) - hirb/hirber alternative, doesn't support vertical tables
ConsoleExtender.load_extensions(
  %w[
    english
    pm()
    amazing_print
    hirber
    interactive_editor
  ]
)

colored_ext_names = ConsoleExtender.extensions.map do |extension_name, result|
  ansi_color(extension_name, result[:loaded] ? :GREEN : :RED)
end

puts "~> Console extensions: #{colored_ext_names.join(' | ')}"

ConsoleExtender.configure_extension('hirber') do
  class Hirb::Helpers::Table # rubocop:disable Lint/ConstantDefinitionInBlock, Style/ClassAndModuleChildren, Style/Documentation
    remove_const(:MIN_FIELD_LENGTH)
    MIN_FIELD_LENGTH = 10
  end
  # Alternative: ~/.hirb.yml
  # Hirb.config[:output]['ActiveRecord::Base'][:vertical] = true
  # Hirb.enable(output: { 'Asset' => { options: { vertical: true } } })

  Hirb.enable
  extend Hirb::Console
end

# ConsoleExtender.configure_extension('table_print') do
#   tp.set :max_width, 15
# end
