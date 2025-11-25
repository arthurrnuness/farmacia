require 'net/http'
require 'uri'
require 'json'

class MensagemDiariaJob < ApplicationJob
  queue_as :default

  def perform
    uri = URI("http://localhost:8080/message/sendText/farmacia")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 10
    
    request = Net::HTTP::Post.new(uri.path)
    request['apikey'] = 'teste123'
    request['Content-Type'] = 'application/json'
    
    request.body = {
      number: "5585981471014",
      options: {
        delay: 0
      },
      textMessage: {
        text: "Teste deu certo!"
      }
    }.to_json
    
    response = http.request(request)
    
    puts "Status: #{response.code}"
    puts "Body: #{response.body}"
    
    response
  end
end