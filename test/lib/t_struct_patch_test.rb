# typed: true
# frozen_string_literal: true

require "test_helper"

class TStructPatchTest < ActiveSupport::TestCase
  class TestStruct < T::Struct
    const :name, String
    const :age, Integer
  end

  class BooleanStruct < T::Struct
    const :enabled, T::Boolean
  end

  # deserialize_from!

  test "deserialize_from! returns struct from hash" do
    struct = TestStruct.deserialize_from!(:hash, { name: "Alice", age: 30 })

    assert_equal "Alice", struct.name
    assert_equal 30, struct.age
  end

  test "deserialize_from! returns struct from json" do
    json = '{"name":"Bob","age":25}'
    struct = TestStruct.deserialize_from!(:json, json)

    assert_equal "Bob", struct.name
    assert_equal 25, struct.age
  end

  test "deserialize_from! raises on invalid input" do
    assert_raises(Typed::Validations::RequiredFieldError) { TestStruct.deserialize_from!(:hash, { name: "Alice" }) }
  end

  test "deserialize_from! coerces boolean strings with wannabe_bool" do
    struct = BooleanStruct.deserialize_from!(:hash, { enabled: "true" })

    assert struct.enabled
  end

  test "deserialize_from! coerces common boolean representations" do
    assert BooleanStruct.deserialize_from!(:hash, { enabled: "yes" }).enabled
    assert BooleanStruct.deserialize_from!(:hash, { enabled: "1" }).enabled
    assert_not BooleanStruct.deserialize_from!(:hash, { enabled: "no" }).enabled
    assert_not BooleanStruct.deserialize_from!(:hash, { enabled: "0" }).enabled
    assert_not BooleanStruct.deserialize_from!(:hash, { enabled: "banana" }).enabled
  end

  # serialize_to!

  test "serialize_to! returns hash" do
    struct = TestStruct.new(name: "Alice", age: 30)
    result = struct.serialize_to!(:hash, options: { should_serialize_values: true })

    assert_equal({ name: "Alice", age: 30 }, result)
  end

  test "serialize_to! returns json" do
    struct = TestStruct.new(name: "Alice", age: 30)
    result = struct.serialize_to!(:json, options: { should_serialize_values: true })

    assert_equal({ "name" => "Alice", "age" => 30 }, JSON.parse(result))
  end

  # to_h

  test "to_h returns hash with serialized values" do
    struct = TestStruct.new(name: "Alice", age: 30)

    assert_equal({ name: "Alice", age: 30 }, struct.to_h)
  end

  test "to_h works with nested structs" do
    struct = RemoteConfig::Struct::BlockConfig.new(
      title: "Blocked",
      text: "App is blocked",
      button: RemoteConfig::Struct::Button.new(text: "Update", url: "https://example.com"),
    )
    result = struct.to_h

    assert_equal "Blocked", result[:title]
    assert_equal "App is blocked", result[:text]
    assert_equal({ text: "Update", url: "https://example.com" }, result[:button])
  end
end
