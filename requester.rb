module TicketSharing
  class Requester

    def initialize(params)
      @params = params
    end

    def email
      @params[:email]
    end

    def name
      @params[:name]
    end

    def uuid
      @params[:uuid]
    end

  end
end
