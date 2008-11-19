#!/usr/bin/env ruby
# spetskhran -- catalogs and finds things that have been erased from history

require 'grit'
require 'digest/sha1'
require 'set'

def ancestors(commit, seen)
  worklist = [commit]
  worklist.each do |cm|
    seen.merge([cm].to_set)
    print $headnm, ": ", cm, " --> ", seen.length(), "\n"
    cm.parents.each {|parent| worklist << parent if not seen.include?(parent) }
  end
  seen
end

def all_commits(repo)
  seen = [].to_set
  repo.heads.each do |head| 
    $headnm=head.name
    seen.merge(ancestors(head.commit, seen)) 
  end
  seen
end
