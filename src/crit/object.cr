module Crit
  class Object
    def initialize(sha)
      @sha = sha
    end

    def write(&block)
      object_directory = "#{OBJECTS_DIRECTORY}/#{@sha[0..1]}"
      Dir.mkdir_p object_directory
      object_path = "#{OBJECTS_DIRECTORY}/#{@sha[2..-1]}"
      File.open(object_path, "w", &block)
    end
  end
end
