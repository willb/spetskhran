#!/usr/bin/env ruby
# spetskhran -- catalogs and finds things that have been erased from history

require 'rubygems'
require 'grit'
require 'digest/sha1'
require 'set'

include Grit

DEBUG=false

def ancestors(commit, seen)
  worklist = [commit]
  worklist.each do |cm|
    if not seen.include?(cm.sha)
      yield cm.sha
      seen.add(cm.sha)

      print $headnm, ": ", cm, " --> ", $seen.length(), "\n" if DEBUG
      cm.parents.each do |parent|
        if not seen.include?(parent.sha)
          worklist << parent
        end
      end
    end
  end
end

def all_commits(repo)
  seen = [].to_set
  repo.heads.each do |head| 
    hc = head.commit
    if not seen.include?(hc.sha)
      ancestors(hc, seen) do |sha|
        seen.add(sha)
        yield sha
      end
    end
  end
end

repo = Repo.new(ARGV[0])

total = 0

all_commits(repo) do |sha| 
  total = total + 1
  print sha, "; total --> " , total, "\n"
end
