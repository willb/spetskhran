#!/usr/bin/env ruby
# spetskhran -- catalogs and finds things that have been erased from history

require 'rubygems'
require 'grit'
require 'digest/sha1'
require 'set'

include Grit

DEBUG=false

# breadth-first search for ancestors of a given commit.  ignores
# commits already seen
def ancestors(commit, seen)
  worklist = [commit]
  worklist.each do |cm|
    if not seen.include?(cm.sha)
      seen.add(cm.sha)
      print $headnm, ": ", cm, " --> ", seen.length(), "\n" if DEBUG
      cm.parents.each do |parent| 
        worklist << parent
      end
    end
  end
  seen
end

# returns a set of hashes corresponding to every commit in a repo,
# using ancestors (breadth-first search)
def all_commits_bfs(repo)
  seen = [].to_set
  
  repo.heads.each do |head| 
    $headnm=head.name if DEBUG
    seen.merge(ancestors(head.commit, seen)) 
  end

  repo.tags.each do |head| 
    $headnm=head.name if DEBUG
    seen.merge(ancestors(head.commit, seen)) 
  end

  repo.remotes.each do |head| 
    $headnm=head.name if DEBUG
    seen.merge(ancestors(head.commit, seen)) 
  end

  seen
end

# returns a set of hashes corresponding to every commit in a repo,
# using the command-line interface exposed by a Repo object.  This is
# by far the fastest way to get all commits.
def all_commits_cmdln(repo)
  repo.git.rev_list({:all => true}).split("\n")
end

def all_commits(repo)
  all_commits_bfs(repo)
end

repo = Repo.new(ARGV[0])

total = 0

all_commits(repo).each do |commit| 
  total = total + 1
  print commit, "; total --> ", total, "\n"
end
