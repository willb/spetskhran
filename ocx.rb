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
    seen.merge([cm].to_set)
    print $headnm, ": ", cm, " --> ", seen.length(), "\n" if DEBUG
    cm.parents.each {|parent| worklist << parent if not seen.include?(parent) }
  end
  seen
end

def all_commits(repo)
  seen = [].to_set
  repo.heads.each do |head| 
    $headnm=head.name if DEBUG
    seen.merge(ancestors(head.commit, seen)) 
  end
  seen
end

repo = Repo.new(ARGV[0])

all_commits(repo).each {|commit| print commit, "\n"}
