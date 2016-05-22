module Ajimi
  class Server
    class Entry
      attr_accessor :path, :mode, :user, :group, :bytes, :date
      
      def initialize(params)
        @path = params[:path]
        @mode = params[:mode]
        @user = params[:user]
        @group = params[:group]
        @bytes = params[:bytes]
        @date = params[:date]
      end
      
      def ==(other)
        self.path == other.path &&
        self.mode == other.mode &&
        self.user == other.user &&
        self.group == other.group &&
        self.bytes == other.bytes &&
        self.date == other.date
      end
      
      def to_s
        "#{@path}, #{@mode}, #{@user}, #{@group}, #{@bytes}, #{@date}"
      end

      def dir?
        @mode[0] == "d"
      end

      def file?
        @mode[0] == "-"
      end
      
      class << self
        def parse(line)
          path, mode, user, group, bytes, date = line.chomp.split(', ')
          Ajimi::Server::Entry.new(
            path: path,
            mode: mode,
            user: user,
            group: group,
            bytes: bytes,
            date: date
          )
        end
      end

    end
  end
end
