require 'ajimi/server/ssh'
require 'ajimi/server/entry'

module Ajimi
  class Server

    def initialize(name, **options)
      @name = name
      @options = options
      @options[:ssh_options] = options[:ssh_options] || {}
      @options[:ssh_options][:host] = options[:ssh_options][:host] || @name
    end

    def ==(other)
      self.instance_variable_get(:@name) == other.instance_variable_get(:@name)
      self.instance_variable_get(:@options) == other.instance_variable_get(:@options)
    end

    def host
      @options[:ssh_options][:host]
    end

    def backend
      @backend ||= Ajimi::Server::Ssh.new(@options[:ssh_options])
    end

    def command_exec(cmd)
      backend.command_exec(cmd)
    end
    
    def find(dir, find_max_depth = nil, detail_paths = [], pruned_paths = [], enable_nice = nil)
      enable_nice = @options[:enable_nice] if enable_nice.nil?
      cmd = build_find_cmd(dir, find_max_depth, detail_paths + pruned_paths, enable_nice, false)
      stdout = command_exec(cmd)
      detail_paths.map do |detail_path|
        cmd = build_find_cmd(detail_path, find_max_depth, pruned_paths, enable_nice, true)
        stdout += command_exec(cmd)
      end
      stdout.split(/\n/).map {|line| line.chomp }.sort
    end

    def entries(dir)
      @entries ||= find(dir).map{ |line| Ajimi::Server::Entry.parse(line) }
    end

    def cat(file)
      stdout = command_exec("sudo cat #{file}")
      stdout.split(/\n/).map {|line| line.chomp }
    end

    def cat_or_md5sum(file)
      stdout = command_exec("if (sudo file -b #{file} | grep text > /dev/null 2>&1) ; then (sudo cat #{file}) else (sudo md5sum #{file}) fi")
      stdout.split(/\n/).map {|line| line.chomp }
    end

    private

    def build_find_cmd(dir, find_max_depth  = nil, pruned_paths = [], enable_nice = false, enable_detail = false)
      p "#{pruned_paths} #{find_max_depth}"
      cmd = "sudo"
      cmd += " nice -n 19 ionice -c 2 -n 7" if enable_nice
      cmd += " find #{dir} -ls"
      cmd += " -maxdepth #{find_max_depth}" if find_max_depth
      cmd += build_pruned_paths_option(pruned_paths)
      if enable_detail
        cmd += " | awk  '{printf \"%s, %s, %s, %s, %s, %s %s %s\\n\", \$11, \$3, \$5, \$6, \$7, \$8, \$9, \$10 }'"
      else
        cmd += " | awk  '{printf \"%s, %s, %s, %s, %s, -\\n\", \$11, \$3, \$5, \$6, \$7}'"
      end
    end

    def build_pruned_paths_option(pruned_paths = [])
      pruned_paths.map{ |path| " -path #{path} -prune" }.join(" -o")
    end

  end
end
