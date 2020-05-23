require "option_parser"
require "./crit/router"
require "./crit/exceptions"

# Makeshift Git
module Crit
  VERSION = "0.1.1"
  SUPPORTED_COMMANDS = ["init", "add", "commit"]

  OptionParser.parse do |parser|
    parser.banner = "Usage: crit <command> [<args>]"

    parser.on "-v", "Show version" do
      puts "Version #{VERSION}"
    end

    parser.on "-h", "Show help" do
      puts parser
    end

    parser.invalid_option do |flag|
      STDERR.puts "Error #{flag} is not a valid option." if flag
      STDERR.puts parser
    end

    parser.unknown_args do |input|
      next if input.empty?
      Router.new(input).dispatch!
    rescue e : Crit::UnknownCommand
      STDERR.puts e.message
      STDERR.puts parser
    end
  end

  nil
end
