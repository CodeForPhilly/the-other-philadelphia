require "bundler"

Bundler.require

require "./the_other_philadelphia"

map "/" do
  run TheOtherPhiladelphiaApp
end
