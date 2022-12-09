# frozen_string_literal: true

module Day7
  File = Struct.new(:name, :filesize)

  # Contains files or other directories!
  class Directory
    attr_reader :name, :entities

    def initialize(name)
      @name = name
      @entities = []
    end

    def filesize
      entities.sum(&:filesize)
    end

    def directories
      entities.select { |entity| entity.is_a?(Directory) }
    end

    def find(name)
      entities.find { |entity| entity.name == name }
    end
  end

  class Parser
    attr_reader :root

    def initialize(input)
      @input = input
      @root = Directory.new('/')
      @path = [root]
    end

    def parse
      input.each_line do |line|
        line = line.chomp

        if line.start_with?('$')
          exec_command(line)
        else
          parse_output(line)
        end
      end
    end

    def cwd
      path.last
    end

    private

    attr_reader :input, :path

    def exec_command(line)
      _, command, args = line.split(/\s+/)

      case command
      when 'cd'
        change_directory(args)
      when 'ls'
        # expect output next
      end
    end

    def change_directory(args)
      case args
      when '/'
        @path = [root]
      when '..'
        @path.pop
      else
        @path << cwd.find(args)
      end
    end

    def parse_output(line)
      dir_or_size, name = line.split(/\s+/, 2)

      new_entity = if dir_or_size == 'dir'
                     Directory.new(name)
                   else
                     File.new(name, dir_or_size.to_i)
                   end

      cwd.entities << new_entity
    end
  end

  class Solutions
    def initialize(input)
      @input = input
    end

    def part_1
      all_directories(parsed_tree)
        .select { |dir| dir.filesize < 100_000 }
        .sum(&:filesize)
    end

    private

    attr_reader :input

    def all_directories(root)
      root.directories.map { |dir| [dir, all_directories(dir)] }.flatten
    end

    def parsed_tree
      @parsed_tree ||= begin
        parser = Parser.new(input)
        parser.parse
        parser.root
      end
    end
  end
end
