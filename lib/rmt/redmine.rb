require 'faraday'
require 'ox'

# A class for reading data from a redmine instance via the REST API.
# There are several gems that purport to be able to do this, and you
# are also supposed to be able to do it directly via ActiveResource;
# However, I kept getting xml type conversion errors with all of them
# and eventually got sick of battling with them, when what we needed
# to accomplish is really easy to just write from scratch.
class RedmineClient
  # Instantiate a redmine client
  #
  # @param [String] base_url the base url (e.g., "https://projects.puppetlabs.com") of the redmine project site to read issues from
  # @param [String] username optional username if authentication is needed.  defaults to nil.
  # @param [String] password optional username if authentication is needed.  defaults to nil.
  def initialize(base_url, username = nil, password = nil)
    @base_url = base_url.sub(/\/$/, "")
    @conn = Faraday.new

    if (username and password)
      @conn.basic_auth(username, password)
    end
  end

  # Get a list of issues for a given project id
  #
  # @param [String] project_id the id of the Redmine project.  You can find this easily by just
  #  pointing your browser to "<base_url>/projects.xml"
  # @param [Hash] options optional hash of extra options for filtering results.  Currently supported:
  #    * :created_date_range : a two-element array where the first element is a String representation of a
  #        start date (in the format "YYYY-MM-DD"), and the second element is a String representation of an
  #        end date.  Either may be nil; if this option is specified, results will be filtered according to
  #        the "created_on" field of the redmine issues.
  # @return [Array] an array of Hashes.  Each item in the array represents an issue from redmine.  Each
  #   issue hash contains the following keys:
  #    * :id
  #    * :subject
  #    * :description
  #    * :start_date
  #    * :due_date
  #    * :done_ratio
  #    * :estimated_hours
  #    * :description
  #    * :created_on
  #    * :updated_on
  #    * :tracker
  #    * :status
  #    * :priority
  #    * :author
  def get_issues_for_project(project_id, options = {})
    uri = "#{@base_url}/issues.xml?project_id=#{project_id}"
    if (options.has_key?(:created_date_range))
      uri << "&created_on=><#{options[:created_date_range][0]}|#{options[:created_date_range][1]}"
    end
    response = @conn.get(uri)
    return parse_issues(response.body)
  end
  
  ###########################################################################
  # Private utility methods
  ###########################################################################

  # parse the http response body (xml) and return a list of issues
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

  # given an Ox xml node, find a child node by the specified child_node_name.  The specified node should
  #  have a single child node itself, which should contain a String.  This method returns that String.
  def get_value_of_text_child_node(node, child_node_name)
    node.locate(child_node_name)[0].nodes[0]
  end
  private :get_value_of_text_child_node

  # given an Ox xml node, find a child node by the specified child_node_name.  The specified node
  #  should have an attribute with the name specified by attr_name; this method returns the value
  #  of that attribute.
  def get_attribute_of_child_node(node, child_node_name, attr_name)
    node.locate(child_node_name)[0][attr_name]
  end
  private :get_attribute_of_child_node
end