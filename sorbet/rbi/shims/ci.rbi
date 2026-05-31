# typed: true
# frozen_string_literal: true

module ::CI
  sig { params(blk: T.proc.void).void }
  def self.run(&blk); end

  sig { params(name: String, command: String).void }
  def step(name, command); end
end