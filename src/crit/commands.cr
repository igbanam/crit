module Crit
  abstract class Command
    abstract def execute
  end

  class InitCommand < Command
    @dirname = uninitialized String
    def initialize(args)
      raise IllegalCommand.new if args.size != 1
      @dirname = args.first
    end

    def execute
      puts "Initializing a crit repository in #{@dirname}"
    end
  end
end
