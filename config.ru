require "bundler"

Bundler.require

require "./what_it_really_means_to_be_hood"

map "/" do
  run WhatItReallyMeansToBeHoodApp
end
