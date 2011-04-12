module TicketSharing
  class Error < StandardError
  end

  class TooManyRedirects < TicketSharing::Error
  end
end
