require 'cora'
require 'siri_objects'
require 'nokogiri'
require 'open-uri'
require 'pp'

class SiriProxy::Plugin::Channels < SiriProxy::Plugin
    def initialize(config = {})
        #if you have custom configuration options, process them here!
    end
      
    
    listen_for /on channel ([0-9,]*[0-9])/i do |number|
    say "Checking for what's playing on channel #{number}"
    request_completed
        end
end