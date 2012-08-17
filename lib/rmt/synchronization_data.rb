module RMT
  class SynchronizationData
    attr_reader :id, :name, :description, :target_list_id, :color

    def initialize(id, name, description, target_list_id, color, relevant_cards_loader)
      @id = id
      @name = name
      @description = description
      @target_list_id = target_list_id
      @color = color
      @relevant_cards_loader = relevant_cards_loader
    end

    def ensure_present_on(trello)
      if not exists_on?(trello)
        insert_into(trello)
      end
    end

    def is_data_for?(card)
      card.name.include? "(#{@id})"
    end

  private

    def insert_into(trello)
      trello.create_card(:name => "(#{@id}) #{@name}",
                         :list => @target_list_id,
                         :description => @description,
                         :color => @color)
    end

    def exists_on?(trello)
      @relevant_cards_loader.call(trello).any? &method(:is_data_for?)
    end
  end
end
