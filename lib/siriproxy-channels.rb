require 'cora'
require 'siri_objects'
require 'pp'


    def initialize(config)
        #if you have custom configuration options, process them here!
    end
    listen_for /test my channels/i do
      say "All is well, Pat"
    
      request_completed
    end
