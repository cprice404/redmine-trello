require 'faraday'
require 'ox'

class RedmineClient
  def initialize(base_url, username = nil, password = nil)
    @base_url = base_url.sub(/\/$/, "")
    @conn = Faraday.new

    if (@username and @password)
      @conn.basic_auth(username, password)
    end
  end

  def get_issues_for_project(project_id, options = {})
    uri = "#{@base_url}/issues.xml?project_id=#{project_id}"
    if (options.has_key?(:created_date_range))
      uri << "&created_on=><#{options[:created_date_range][0]}|#{options[:created_date_range][1]}"
    end
    response = @conn.get(uri)
    return parse_issues(response.body)
  end

  def parse_issues(response_body)
    doc = Ox.parse(response_body)
    issues = []
    doc.root.nodes.each do |issue_node|
      #require 'pp'
      #pp issue_node
      issue = {}
      issue[:id] = get_value_of_text_child_node(issue_node, "id")
      issue[:subject] = get_value_of_text_child_node(issue_node, "subject")
      issue[:description] = get_value_of_text_child_node(issue_node, "description")
      issue[:start_date] = get_value_of_text_child_node(issue_node, "start_date")
      issue[:due_date] = get_value_of_text_child_node(issue_node, "due_date")
      issue[:done_ratio] = get_value_of_text_child_node(issue_node, "done_ratio")
      issue[:estimated_hours] = get_value_of_text_child_node(issue_node, "estimated_hours")
      issue[:description] = get_value_of_text_child_node(issue_node, "description")
      issue[:created_on] = get_value_of_text_child_node(issue_node, "created_on")
      issue[:updated_on] = get_value_of_text_child_node(issue_node, "updated_on")

      issue[:tracker] = get_attribute_of_child_node(issue_node, "tracker", :name)
      issue[:status] = get_attribute_of_child_node(issue_node, "status", :name)
      issue[:priority] = get_attribute_of_child_node(issue_node, "priority", :name)
      issue[:author] = get_attribute_of_child_node(issue_node, "author", :name)

      issues << issue
    end
    issues
  end
  private :parse_issues

  def get_value_of_text_child_node(node, child_node_name)
    node.locate(child_node_name)[0].nodes[0]
  end

  def get_attribute_of_child_node(node, child_node_name, attr_name)
    node.locate(child_node_name)[0][attr_name]
  end
end