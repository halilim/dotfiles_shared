#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'shellwords'

# cSpell:ignore shrc
files = Dir.glob(
  %w[
    **/.*shrc
    **/.bash_profile
    **/.githooks/*
    **/.inputrc
    **/.zprofile
    **/*.bash
    **/*.sh
    **/*.zsh
    **/bin/*
    setup
  ]
).sort # rubocop:disable Lint/RedundantDirGlobSort

files.reject! do |file|
  next true if file.end_with?(
    '.applescript',
    '.p10k.zsh',
    '.rb',
    'ghostty_tab',
    'iterm_tab',
    'smerge'
  )
  next true if file.include?('osascript_')
  next true if file.include?('url_to_')

  if File.size?(file)
    first_line = File.open(file, &:readline)
    next true if first_line.start_with?('#!') && !first_line.include?('ruby')
  end
rescue StandardError => e
  warn "#{file}: #{e}"
  false
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
