module TicketSharing
  def self.connection
    @connection ||= Faraday.new
  end

  def self.connection=(new_connection)
    @connection = new_connection
  end
end
