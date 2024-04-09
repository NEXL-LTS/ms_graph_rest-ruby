require 'camel_snake_struct'

module MsGraphRest
  class Contacts
    class Response < CamelSnakeStruct
      def initialize(data)
        @data = data
        super(data)
      end

      def next_get_query
        return nil unless odata_next_link

        uri = URI.parse(odata_next_link)
        params = CGI.parse(uri.query)
        { select: params["$select"]&.first,
          skip: params["$skip"]&.first,
          filter: params["$filter"]&.first,
          order_by: params["$orderBy"]&.first,
          top: params["$top"]&.first }.compact
      end
    end
    Response.example('value' => [], "@odata.context" => "", "@odata.nextLink" => "")
    Response.example(MultiJson.load(File.read("#{__dir__}/contacts_example.json")))

    class SaveOptions < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess

      property :assistantName, from: :assistant_name
      property :birthday
      property :businessAddress, from: :business_address
      property :businessHomePage, from: :business_home_page
      property :businessPhones, from: :business_phones
      property :categories
      property :children
      property :companyName, from: :company_name
      property :department
      property :displayName, from: :display_name
      property :emailAddresses, from: :email_addresses
      property :fileAs, from: :file_as
      property :generation
      property :givenName, from: :given_name
      property :homeAddress, from: :home_address
      property :homePhones, from: :home_phones
      property :imAddresses, from: :im_addresses
      property :initials
      property :jobTitle, from: :job_title
      property :manager
      property :middleName, from: :middle_name
      property :mobilePhone, from: :mobile_phone
      property :nickName, from: :nick_name
      property :officeLocation, from: :office_location
      property :otherAddress, from: :other_address
      property :parentFolderId, from: :parent_folder_id
      property :personalNotes, from: :personal_notes
      property :profession
      property :spouseName, from: :spouse_name
      property :surname
      property :title
    end

    class SaveResponse < Hashie::Trash
      include Hashie::Extensions::IndifferentAccess
      include Hashie::Extensions::IgnoreUndeclared

      property :id
      property :assistant_name, from: :assistantName
      property :birthday
      property :business_address, from: :businessAddress
      property :business_home_page, from: :businessHomePage
      property :business_phones, from: :businessPhones
      property :categories
      property :children
      property :company_name, from: :companyName
      property :department
      property :display_name, from: :displayName
      property :email_addresses, from: :emailAddresses
      property :file_as, from: :fileAs
      property :generation
      property :given_name, from: :givenName
      property :home_address, from: :homeAddress
      property :home_phones, from: :homePhones
      property :im_addresses, from: :imAddresses
      property :initials
      property :job_title, from: :jobTitle
      property :manager
      property :middle_name, from: :middleName
      property :mobile_phone, from: :mobilePhone
      property :nick_name, from: :nickName
      property :office_location, from: :officeLocation
      property :other_address, from: :otherAddress
      property :parent_folder_id, from: :parentFolderId
      property :personal_notes, from: :personalNotes
      property :profession
      property :spouse_name, from: :spouseName
      property :surname
      property :title
    end

    attr_reader :client, :path, :query

    def initialize(path, client:, query: {})
      @path = "#{path.to_str}".gsub('//', '/')
      @path[0] = '' if @path.start_with?('/')
      @client = client
      @query = query
    end

    def get(select: nil, skip: nil, filter: nil, top: nil, order_by: nil)
      Response.new(client.get("#{path}/contacts", query.merge({ '$skip' => skip,
                                                                '$select' => select,
                                                                '$filter' => filter,
                                                                '$top' => top,
                                                                '$orderBy' => order_by }.compact)))
    end

    def update(id, options)
      options = SaveOptions.new(options.to_hash)
      SaveResponse.new(client.patch("#{path}/contacts/#{id.to_str}", options))
    end

    def create(options)
      options = SaveOptions.new(options.to_hash)
      SaveResponse.new(client.post("#{path}/contacts/", options))
    end

    def select(val)
      val = val.map(&:to_s).map { |v| v.camelize(:lower) }.join(',') if val.is_a?(Array)
      new_with_query(query.merge('$select' => val))
    end

    def filter(val)
      new_with_query(query.merge('$filter' => val))
    end

    def filter_email(val)
      address = val.to_str.gsub("'", "''")
      new_with_query(query.merge('$filter' => "emailAddresses/any(a:a/address eq '#{address}')"))
    end

    def order_by(val)
      new_with_query(query.merge('$orderBy' => val))
    end

    private

    def new_with_query(query)
      self.class.new(path, client: client, query: query)
    end
  end
end
