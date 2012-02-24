require 'cora'
require 'siri_objects'
require 'pp'

class SiriProxy::Plugin::Example < SiriProxy::Plugin
    
    listen_for /test my channels/i do
      say "All is well, Pat"
    
      request_completed
    end
end