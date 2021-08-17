module MsGraphRest
  class ModifyingAction
    attr_reader :client, :query
    def initialize(client:)
      @client = client
    end

    def create()
      raise NotImplementedError
    end
  end
end

