require 'rmt/trello'

module RMT
  class Synchronize
    def initialize
      @trello_list_data = {}
    end

    def synchronize(data, to_trello)
      list_data = (@trello_list_data[to_trello] ||= [])
      list_data.concat(data)
      self
    end

    def finish
      @trello_list_data.each do |list, data|
        trello = RMT::Trello.new(list.app_key,
                                 list.secret,
                                 list.user_token)

        existing_cards = trello.list_cards_in(list.target_list_id)

        existing_cards.
          reject { |card| data.any? { |data| data.is_data_for? card } }.
          each do |card|
            puts "Removing card: #{card.name}"
            trello.archive_card(card)
          end

        data.
          reject { |data| existing_cards.any? { |card| data.is_data_for? card } }.
          each { |data| data.insert_into(trello) }
      end
    end
  end
end
