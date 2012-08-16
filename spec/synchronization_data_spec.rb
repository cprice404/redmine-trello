require 'minitest/autorun'
require 'ramcrest'

require 'rmt/synchronization_data'

describe RMT::SynchronizationData do
  include Ramcrest::Is
  include Ramcrest::HasAttribute

  Card = Struct.new(:name)

  it "determines if it is the data for a card with a matching id" do
    card = Card.new("(id) some name")

    data = RMT::SynchronizationData.new("id", "name", "description", "list", "color")

    assert_that data.is_data_for?(card), is(true)
  end

  it "does not match a card with a different id" do
    card = Card.new("(other id) some name")

    data = RMT::SynchronizationData.new("id", "name", "description", "list", "color")

    assert_that data.is_data_for?(card), is(false)
  end

  it "can create itself from a Redmine issue" do
    issue = {
      :id => 1,
      :subject => "a small subject",
      :description => "a longer description",
      :tracker => "bugger"
    }
    list_config = Struct.new(:target_list_id, :color_map).new(23, { "bugger" => "blue" })

    data = RMT::SynchronizationData.from_redmine(list_config).call(issue)

    assert_that data, has_attribute(:id, is(1))
    assert_that data, has_attribute(:name, is("a small subject"))
    assert_that data, has_attribute(:description, is("a longer description"))
    assert_that data, has_attribute(:target_list_id, is(23))
    assert_that data, has_attribute(:color, is("blue"))
  end
end
