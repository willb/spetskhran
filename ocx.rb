#!/usr/bin/env ruby
# spetskhran -- catalogs and finds things that have been erased from history

require 'grit'
require 'digest/sha1'
require 'set'

def ancestors(commit)
  seen = [].to_set
  worklist = [commit]
  while not worklist.empty?
    commit = worklist.delete_at(0)
    seen.merge([commit].to_set)
    (commit.parents.to_set - seen).each {|parent| worklist << parent}
  end
  seen
end

def all_commits(repo)
  seen = [].to_set
  repo.heads.each { |head| seen = seen | ancestors(head.commit) }
  seen
end