require 'cora'
require 'siri_objects'
require 'nokogiri'
require 'open-uri'
require 'pp'

class SiriProxy::Plugin::Channels < SiriProxy::Plugin
    def initialize(config = {})
        #if you have custom configuration options, process them here!
    end
      
    
    listen_for /Whats playing on channel/i do
    say "Your mom"
    request_completed
        end
end