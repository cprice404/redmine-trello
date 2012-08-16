module RMT
  class SynchronizationData
    attr_reader :id, :name, :description, :target_list_id, :color

    def initialize(id, name, description, target_list_id, color)
      @id = id
      @name = name
      @description = description
      @target_list_id = target_list_id
      @color = color
    end

    def insert_into(trello)
      puts "Adding issue: #{@id}: #{@name}"
      trello.create_card(:name => "(#{@id}) #{@name}",
                         :list => @target_list_id,
                         :description => @description,
                         :color => @color)
    end

    def is_data_for?(card)
      card.name.include? "(#{@id})"
    end

    def ensure_present_on(trello)
      if not exists_on?(trello)
        insert_into(trello)
      end
    end

    def exists_on?(trello)
      trello.list_cards_in(@target_list_id).any? &method(:is_data_for?)
    end

    def self.from_redmine(list_config)
      proc { |ticket| SynchronizationData.new(ticket[:id], ticket[:subject], ticket[:description], list_config.target_list_id, list_config.color_map[ticket[:tracker]]) }
    end
  end
end
