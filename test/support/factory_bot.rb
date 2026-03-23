# typed: true
# frozen_string_literal: true

FactoryBot.definition_file_paths = ["test/factories"]
FactoryBot.find_definitions

class Minitest::Test
  include FactoryBot::Syntax::Methods
end
