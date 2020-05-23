require "digest"
require "zlib"
require "./datatypes"

module Crit
    CRIT_DIRECTORY = ".crit"
    OBJECTS_DIRECTORY = "#{CRIT_DIRECTORY}/objects"
    REFS_DIRECTORY = "#{CRIT_DIRECTORY}/refs"
    INDEX_PATH = "#{CRIT_DIRECTORY}/index"

  abstract class Command
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
        file.puts "ref: refs/heads/master"
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

  class CommitCommand < Command
    alias NestedStringHash = Nil | String | Hash(String, NestedStringHash)
    COMMIT_MESSAGE_TEMPLATE = "# Title\n#\n# Body"

    def initialize(args : Array(String))
      raise IllegalCommand.new unless args.empty?
    end

    def execute
      if stage_clear?
        puts "Nothing to commit."
        return
      end

      root_sha = build_tree("root", index_tree)
      commit_sha = build_commit(tree: root_sha)
      update_ref(commit_sha: commit_sha)
      clear_stage
    end

    private def index_tree
      tree = {} of String => NestedStringHash
      File.open(INDEX_PATH).each_line.each_with_object(tree) do |line, node|
        sha, path = line.split
        segments = path.split("/")
        segments.reduce(node) do |memo, s|
          if s == segments.last
            memo.as(Hash)[s] = sha
            memo
          else
            next if memo.as(Hash).has_key?(s)
            memo.as(Hash)[s] ||= {} of String => NestedStringHash
            memo.as(Hash)[s]
          end
        end
      end
    end

    private def build_tree(name, tree : Hash(String, NestedStringHash))
      sha = Digest::SHA1.hexdigest(Time.utc.to_s + name)
      object = Crit::Object.new(sha)

      object.write do |file|
        tree.each do |key, value|
          if value.is_a? Hash
            dir_sha = build_tree(key, value)
            file.puts "tree #{dir_sha} #{key}"
          else
            file.puts "blob #{value} #{key}"
          end
        end
      end

      sha
    end

    private def build_commit(tree)
      commit_message_path = "#{CRIT_DIRECTORY}/COMMIT_EDITMSG"

      `echo "#{COMMIT_MESSAGE_TEMPLATE}" > #{commit_message_path}`
      `vim #{commit_message_path} >/dev/tty`

      message = File.read(commit_message_path)
      committer = "igbanam"
      sha = Digest::SHA1.hexdigest(Time.utc.to_s + committer)
      object = Crit::Object.new(sha)

      object.write do |file|
        file.puts "tree #{tree}"
        file.puts "author #{committer}"
        file.puts
        file.puts message
      end

      sha
    end

    private def update_ref(commit_sha)
      current_branch = File.read("#{CRIT_DIRECTORY}/HEAD").strip.split.last
      File.open("#{CRIT_DIRECTORY}/#{current_branch}", "w") do |file|
        file.print commit_sha
      end
    end

    private def clear_stage
      # This method could be a candidate for refactoring, together with its
      # sister: stage_clear?. These hint that there's something like a stage
      # which had actions that can be performed on it
      File.open(INDEX_PATH, "w") do |file|
        file.truncate
      end
    end

    private def stage_clear?
      !File.exists?(INDEX_PATH) || File.empty?(INDEX_PATH)
    end
  end
end
