#!/usr/bin/env ruby
# frozen_string_literal: true

require 'shellwords'
require 'socket'

port = ENV.fetch('PORT', 8088)
url = "http://localhost:#{port}"
puts "Server running on #{url}"
`NEWLINE=NO iterm_tab . http #{url.shellescape}`

server = TCPServer.new('localhost', port)

begin
  loop do
    client = server.accept

    response_lines = [
      'REQUEST:',
      '--------'
    ]

    # 1. Read Request Line & Headers
    headers = {}
    response_lines << client.gets.chomp

    # Loop until an empty line (CRLF) is reached
    while (line = client.gets) && (line.chomp != '')
      response_lines << line.chomp
      key, value = line.split(':', 2)
      headers[key.strip.downcase] = value.strip if key && value
    end

    # 2. Read Request Body (if Content-Length is sent)
    content_length = headers['content-length']&.to_i
    if content_length && content_length > 0
      response_lines << ''
      # Read exactly content_length bytes from the TCP socket
      response_lines << client.read(content_length)
    end

    response_body = response_lines.join("\n")

    client.puts 'HTTP/1.1 200 OK'
    client.puts 'Content-Type: text/plain'
    client.puts "Content-Length: #{response_body.bytesize}"
    client.puts 'Connection: close'
    client.puts '' # Mandatory empty line separating headers from body
    client.puts response_body

    client.close
  end
rescue Interrupt
  puts "\nInterrupt received. Shutting down..."
ensure
  server&.close
end
