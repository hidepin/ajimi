require 'ajimi/diff'

module Ajimi
  class Checker
    include Ajimi::Diff

    def initialize(source, target, root)
      @source = source
      @target = target
      @root = root
    end
    
    def check
      source_entries = @source.entries(@root)
      target_entries = @target.entries(@root)

      @diffs = diff_entries(source_entries, target_entries)
      @diffs.empty?
    end

  end
end
