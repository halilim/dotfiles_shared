# frozen_string_literal: true

require Pathname.new(__FILE__).dirname.dirname.join('includes', 'lib', 'ruby_rails', 'ruby_common')

# \rubocop:disable Style/AsciiComments
# pretty prompt
# Pry.config.prompt = [
#   proc do |object, nest_level, _pry|
#     prompt = colour(:bright_black, Pry.view_clip(object))
#     prompt += ":#{nest_level}" if nest_level > 0
#     prompt += colour(:cyan, ' » ')
#   end,
#   proc { |_object, _nest_level, _pry| colour(:cyan, '» ') }
# ]
# \rubocop:enable Style/AsciiComments

# # tell Readline when the window resizes
# old_winch = trap 'WINCH' do
#   if `stty size` =~ /\A(\d+) (\d+)\n\z/
#     Readline.set_screen_size(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i)
#   end
#   old_winch&.call
# end

# startup hooks
org_logger_active_record = nil
org_logger_rails         = nil
Pry.hooks.add_hook(:before_session, :rails) do |_output, _target, _pry|
  # show ActiveRecord SQL queries in the console
  if defined? ActiveRecord
    org_logger_active_record  = ActiveRecord::Base.logger
    new_logger                = Logger.new($stdout)
    new_logger.formatter      = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n"
    end
    ActiveRecord::Base.logger = new_logger
  end
  #   if defined?(ActiveRecord) && defined?(ActiveSupport::Notifications)
  #     $odd_or_even_queries = false
  #     ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
  #       $odd_or_even_queries = !$odd_or_even_queries
  #       color = $odd_or_even_queries ? ANSI_COLORS[:CYAN] : ANSI_COLORS[:MAGENTA]
  #       event = ActiveSupport::Notifications::Event.new(*args)
  #       p event.payload[:binds][1]
  #       time  = "%.1fms" % event.duration
  #       name  = event.payload[:name]
  #       sql   = event.payload[:sql].gsub("\n", " ").squeeze(" ")
  #       puts "  #{ANSI_COLORS[:UNDERLINE]}#{color}#{name} (#{time})#{ANSI_COLORS[:RESET]}  #{sql}"
  #     end
  #   end

  if defined?(Rails) && Rails.env
    # output all other log info such as deprecation warnings to the console
    if Rails.respond_to?(:logger=)
      org_logger_rails = Rails.logger
      Rails.logger     = Logger.new($stdout)
    end

    # load Rails console commands
    if Rails::VERSION::MAJOR >= 3
      require 'rails/console/app'
      require 'rails/console/helpers'
      extend Rails::ConsoleMethods if Rails.const_defined?(:ConsoleMethods)
    else
      require 'console_app'
      require 'console_with_helpers'
    end
  end
end

Pry.hooks.add_hook(:after_session, :rails) do |_output, _target, _pry|
  ActiveRecord::Base.logger = org_logger_active_record if org_logger_active_record
  Rails.logger              = org_logger_rails if org_logger_rails
end

if defined?(PryByebug)
  %w[_b _w where].each { |a| Pry.commands.alias_command(a, 'backtrace') }
  Pry.commands.alias_command('_c', 'continue')
  Pry.commands.alias_command('_f', 'finish')
  Pry.commands.alias_command('_n', 'next')
  Pry.commands.alias_command('_s', 'step')
  Pry.commands.alias_command('_u', 'up')
end

ConsoleExtender.configure_extension('amazing_print') do
  # https://github.com/pry/pry/wiki/FAQ#how-can-i-use-awesome_print-with-pry - with pager
  Pry.config.print = proc do |output, value|
    Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)
  end
  # AmazingPrint.pry! - without pager, eq to the first example in the link above
end

ConsoleExtender.configure_extension('hirber') do
  # https://github.com/pry/pry/wiki/FAQ#hirb

  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end
end
