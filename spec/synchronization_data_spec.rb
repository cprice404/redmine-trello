require 'minitest/autorun'
require 'ramcrest'

require 'rmt/synchronization_data'

describe RMT::SynchronizationData do
  include Ramcrest::Is
  include Ramcrest::HasAttribute

  Card = Struct.new(:name)

  it "does not add a card if one is already present" do
    trello = MiniTest::Mock.new
    card_finder = MiniTest::Mock.new
    card_finder.expect(:call, [Card.new("(id) some name")], [trello])

    data = RMT::SynchronizationData.new("id", "name", "description", "list", "color", card_finder)
    data.ensure_present_on(trello)

    card_finder.verify
  end

  it "adds a new card if one is not present" do
    trello = MiniTest::Mock.new
    trello.expect(:create_card, nil, [{ :name => "(id) name", :list => "list", :description => "description", :color => "color" }])

    card_finder = MiniTest::Mock.new
    card_finder.expect(:call, [Card.new("(different id) some name")], [trello])

    data = RMT::SynchronizationData.new("id", "name", "description", "list", "color", card_finder)
    data.ensure_present_on(trello)

    trello.verify
  end
end
