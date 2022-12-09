# frozen_string_literal: true

require_relative './day7'

RSpec.describe Day7::Directory do
  subject { described_class.new('/') }

  describe '#filesize' do
    it 'sums the files within itself' do
      subject.entities << Day7::File.new('one', 1)
      subject.entities << Day7::File.new('two', 2)

      expect(subject.filesize).to eq(3)
    end

    it 'sums files within subdirectories too' do
      subdirectory = described_class.new('sub')
      subdirectory.entities << Day7::File.new('one', 1)
      subdirectory.entities << Day7::File.new('two', 2)

      subject.entities << subdirectory

      expect(subject.filesize).to eq(3)
    end
  end
end

RSpec.describe Day7::Parser do
  subject { described_class.new(input) }

  describe '#parse' do
    describe 'cd command' do
      context 'when directory is /' do
        let(:input) { '$ cd /' }

        it 'sets cwd to the root' do
          subject.parse

          expect(subject.cwd.name).to eq('/')
        end
      end

      context 'when directory is named' do
        let(:input) do
          <<~EOF
            $ ls
            dir a
            $ cd a
          EOF
        end

        it 'descends into that directory' do
          subject.parse

          expect(subject.cwd.name).to eq('a')
        end
      end

      context 'when directory is ..' do
        let(:input) do
          <<~EOF
            $ ls
            dir a
            $ cd a
            $ cd ..
          EOF
        end

        it 'traverses up one level' do
          subject.parse

          expect(subject.cwd.name).to eq('/')
        end
      end
    end

    describe 'ls command' do
      context 'with a dir' do
        let(:input) do
          <<~EOF
            $ ls
            dir a
          EOF
        end

        it 'adds a directory to the cwd entities' do
          subject.parse

          directory = subject.cwd.entities.last

          expect(directory.name).to eq('a')
        end
      end

      context 'with a number' do
        let(:input) do
          <<~EOF
            $ ls
            123 file
          EOF
        end

        it 'adds a file to the  cwd entities' do
          subject.parse

          file = subject.cwd.entities.last

          expect(file.name).to eq('file')
          expect(file.filesize).to eq(123)
        end
      end
    end
  end
end

RSpec.describe Day7::Solutions do
  subject { described_class.new(input) }

  let(:example_input) do
    <<~EOF
      $ cd /
      $ ls
      dir a
      14848514 b.txt
      8504156 c.dat
      dir d
      $ cd a
      $ ls
      dir e
      29116 f
      2557 g
      62596 h.lst
      $ cd e
      $ ls
      584 i
      $ cd ..
      $ cd ..
      $ cd d
      $ ls
      4060174 j
      8033020 d.log
      5626152 d.ext
      7214296 k
    EOF
  end

  describe '#part_1' do
    context 'example input' do
      let(:input) { example_input }

      it 'totals up all directories under 100,000 in size' do
        expect(subject.part_1).to eq(95_437)
      end
    end

    context 'real input' do
      let(:input) { File.read(File.join(__dir__, 'input.txt')) }

      it 'totals up to a mystery amount' do
        expect(subject.part_1).to eq(1_642_503)
      end
    end
  end

  describe '#part_2' do
    context 'example input' do
      let(:input) { example_input }

      it 'returns the smallest directory that will free 8381165' do
        expect(subject.part_2).to eq(24_933_642)
      end
    end

    context 'real input' do
      let(:input) { File.read(File.join(__dir__, 'input.txt')) }

      it 'totals up to a mystery amount' do
        expect(subject.part_2).to eq(6_999_588)
      end
    end
  end
end
