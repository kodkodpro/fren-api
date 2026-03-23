# typed: true
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  nilify_blanks
  primary_abstract_class
end
