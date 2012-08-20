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

        data.each { |data| data.ensure_present_on(trello) }
        trello.list_cards_in(list.target_list_id).each { |card| ensure_needed(trello, card, data) }
      end
    end

  private

    def ensure_needed(trello, card, data)
      if not data.any? { |data| data.is_data_for? card }
        trello.archive_card card
      end
    end
  end
end
