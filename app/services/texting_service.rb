class TextingService

  def self.send(to:, body:)
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_ID'], ENV['TWILIO_AUTH_TOKEN'])
    text_params = {
      from: '+12052364969',
      to: to,
      body: body
    }

    client.messages.create(text_params)
  end

end