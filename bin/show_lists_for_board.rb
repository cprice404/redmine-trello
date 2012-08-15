#!/usr/bin/env ruby

$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "config")
$LOAD_PATH << File.join(File.absolute_path(File.dirname(__FILE__)), "..", "lib")

require 'rmt_config'
require 'redmine_trello_conf'
require 'trello_utils'

def usage()
  puts "Usage: #{$0} <TRELLO_BOARD_ID>"
  puts
  puts "A simple CLI to retrieve the ids of all of the Trello Lists for a given Trello Board ID."
end

unless board_id = ARGV[0]
  usage()
  exit(1)
end

RMTConfig.mappings.each do |mapping|
	TrelloUtils.initialize_auth(mapping.trello.app_key,
															mapping.trello.secret,
															mapping.trello.user_token)

	begin
		board = Trello::Board.find(board_id)
	rescue Trello::Error => e
		puts "Unable to find board with id '#{board_id}'. (#{e.to_s.strip()})"
		exit(1)
	end

	puts "Board found; name: '#{board.name}'"

	board.lists.each do |list|
		puts "\tList '#{list.name}' has id '#{list.id}'"
	end
end
