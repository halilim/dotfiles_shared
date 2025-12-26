#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'shellwords'

# cSpell:ignore shrc
files = Dir.glob(
  %w[
    **/.*sh
    **/.*shrc
    **/.bash_profile
    **/.githooks/*
    **/.inputrc
    **/.zprofile
    **/*.*sh
    **/bin/*
    setup
  ]
).sort # rubocop:disable Lint/RedundantDirGlobSort

files.reject! do |file|
  file.end_with?(
    '.applescript',
    '.p10k.zsh',
    '.rb',
    'iterm_tab',
    'smerge'
  ) ||
    file.include?('osascript_') ||
    file.include?('url_to_')
end

unless ARGV.empty?
  files &= ARGV
  exit if files.empty?
end

if ENV['DRY_RUN']
  pp files
else
  system((%w[shellcheck -s bash] + files).shelljoin)
  exit $CHILD_STATUS.exitstatus
end
