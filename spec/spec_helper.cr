require "spec"
require "../src/cryox"

def output_of
  Stdio.capture do |io|
    yield
    io.out.gets_to_end
  end
end
