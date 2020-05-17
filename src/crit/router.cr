require "./exceptions"
require "./commands"

module Crit
  class Router
    @intent = uninitialized String
    @args = [] of String

    def initialize(input : Array(String))
      @intent = input.first
      @args = input[1..-1]
    end

    def dispatch!
      reject! unless supported?

      route.execute
    end

    def supported?
      SUPPORTED_COMMANDS.includes? @intent
    end

    def route
      case @intent
      when "init"
        Crit::InitCommand.new(@args)
      when "add"
        Crit::AddCommand.new(@args)
      when "commit"
        Crit::CommitCommand.new(@args)
      else
        reject!
      end
    end

    private def reject!
      error_message = "Unsupported command: '#{@intent}'"
      raise Crit::UnknownCommand.new error_message
    end
  end
end
