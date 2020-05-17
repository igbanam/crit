module Crit
  abstract class Command
    abstract def execute
  end

  class InitCommand < Command
    CRIT_DIRECTORY = ".crit"
    OBJECTS_DIRECTORY = "#{CRIT_DIRECTORY}/objects"
    REFS_DIRECTORY = "#{CRIT_DIRECTORY}/refs"

    def initialize(args)
      raise IllegalCommand.new if args.size > 0
    end

    def execute
      if Dir.exists? CRIT_DIRECTORY
        STDERR.puts "You're in a crit project"
        return
      end

      Dir.mkdir CRIT_DIRECTORY
      create_objects_directory
      create_refs_directory
      initialize_head

      puts "Crit initialized in #{Dir.current}/#{CRIT_DIRECTORY}"
    end

    def create_refs_directory
      Dir.mkdir REFS_DIRECTORY
      Dir.mkdir "#{REFS_DIRECTORY}/heads"
      Dir.mkdir "#{REFS_DIRECTORY}/tags"
    end

    def create_objects_directory
      Dir.mkdir OBJECTS_DIRECTORY
      Dir.mkdir "#{OBJECTS_DIRECTORY}/info"
      Dir.mkdir "#{OBJECTS_DIRECTORY}/pack"
    end

    def initialize_head
      File.open("#{CRIT_DIRECTORY}/HEAD", "w") do |file|
        file.puts "ref: refs/head/master"
      end
    end
  end
end
