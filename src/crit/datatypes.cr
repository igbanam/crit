module Crit
  class Object
    def initialize(@sha : String)
    end

    def write
      object_directory = "#{OBJECTS_DIRECTORY}/#{@sha[0..1]}"
      Dir.mkdir_p object_directory
      object_path = "#{OBJECTS_DIRECTORY}/#{@sha[2..-1]}"
      yield File.open(object_path, "w")
    end
  end
end
