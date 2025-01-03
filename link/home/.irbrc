# frozen_string_literal: true

require Pathname.new(File.readlink(__FILE__)).dirname.dirname.dirname
                .join('includes', 'lib', 'ruby_rails', 'ruby_common').to_s

IRB.conf[:SAVE_HISTORY] = 10_000
