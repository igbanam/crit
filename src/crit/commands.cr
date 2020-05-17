require "digest"
require "zlib"

module Crit
  abstract class Command
    CRIT_DIRECTORY = ".crit"
    OBJECTS_DIRECTORY = "#{CRIT_DIRECTORY}/objects"
    REFS_DIRECTORY = "#{CRIT_DIRECTORY}/refs"
    INDEX_PATH = "#{CRIT_DIRECTORY}/index"

    abstract def execute
  end

  class InitCommand < Command
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

  class AddCommand < Command
    @paths = [] of String

    def initialize(args : Array(String))
      raise IllegalCommand.new("No paths specified") if args.empty?
      @paths = args
    end

    def execute
      unless Dir.exists? CRIT_DIRECTORY
        STDERR.puts "Not a Crit repository"
        return
      end

      @paths.each do |path|
        file_contents = File.read(path)
        sha = Digest::SHA1.hexdigest file_contents
        persist_compressed(sha, file_contents)
        update_index(sha, path)
      end
    end

    private def persist_compressed(sha, file)
      object_directory = "#{OBJECTS_DIRECTORY}/#{sha[0..1]}"
      blob_path = "#{object_directory}/#{sha[2..-1]}"
      Dir.mkdir_p object_directory
      Zlib::Writer.open(blob_path) do |file|
        file.print file
      end
    end

    private def update_index(key, path)
      File.open(INDEX_PATH, "a") do |file|
        file.puts "#{key} #{path}"
      end
    end
  end
end
