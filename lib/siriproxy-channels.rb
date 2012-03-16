require 'cora'
require 'siri_objects'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'httparty'
require 'json'


class SiriProxy::Plugin::Channels < SiriProxy::Plugin
    attr_accessor :ip
    attr_accessor :episode_prefix
    attr_accessor :image_prefix
    def initialize(config = {})
        self.ip = config['host']
        self.episode_prefix = config['episode_prefix']
        self.image_prefix = config['image_prefix']
        #if you have custom configuration options, process them here!
    end
    
    #$ip = '192.168.0.3'
    #$episode_prefix = 'http://tvlistings.aol.com/episodes/'
    #$image_prefix = 'http://media.i.tv.s3.amazonaws.com/channels/black/46x35/'
    number = 0
    word = ""
    
    listen_for /on (fox news|history|the history channel|history channel|truetv|spike tv|comedy central|comedy)/i do |word1|
    
    word = word1
    word = word.downcase
    
    if (word == "fox news")
         number = 38
    elsif (word == "history" ||word == "the history channel" ||word == "history channel")
        number = 48
    elsif (word == "tru tv")
            number = 40
    elsif (word == "spike tv")
            number = 64
    elsif (word == "comedy central" || word == "comedy")
            number = 62
    else
        say "Sorry, I did not recognize your request"
    end
        
    channelCheck(number)
    
    end 

    listen_for /on channel ([0-9,]*[0-9])/i do |number1|
    number = number1.to_i
    channelCheck(number)
    end

    listen_for /to number ([0-9,]*[0-9])/i do |number1|
        number = number1
        
     change_channel number 
    end
    
   listen_for /media center (tv|menu|music|stop|skip|previous)/i do |word1|
       
       word = word1
       word = word.downcase
       controls(word)
       end

    def channelCheck(number)
        
        t = Time.new
        current_time = Time.local(t.year, t.month, t.day, t.hour, t.min/30*30).getutc
        searching = true
        attempts = 0
        
   h = [0, 0, 10780, 10839, 0, 10603, 73442, 21343, 10734, 63705,
        10535, 63823, 10659, 32892, 11069, 46256, 22130, 23325, 
        23326, 22133, 23896, 23897, 10816, 10342, 16715, 11867, 
        53324, 11221, 10183, 11207, 10918, 10145, 23340, 10179,
        12444, 11059, 10142, 16300, 16374, 10989, 10153, 52277, 
        21484, 12574, 14902, 11180, 11150, 16331, 14771, 11158, 
        10057, 10035, 14753, 10139, 44263, 16011, 15952, 15377,
        10021, 11164, 11187, 0,     10150, 16123, 11163, 10138, 
        10986, 11218, 18511, 11066, 17098, 11097, 10269, 10051, 
        10093, 11006, 12510, 18151, 10161, 10162, 10380]
        
       channel_id = h[number]
        channel_id = channel_id.to_s
        while searching do
            
            #die if we've tried too many times
            if attempts == 10
                say "Sorry, but I couldn't find anything."
                request_completed
                
                return
            end

        
        url = self.episode_prefix + channel_id + '_' + current_time.strftime("%Y-%m-%d_%HX%M")
        get_info = HTTParty.get(url).body
        show = JSON.parse(get_info)
        
            if show['title'].nil?
                #didn't find info playing about the current show
                #so go back a half hour until
                #we find valid info from the start of the show
                current_time = current_time - (30 * 60)
                attempts += 1
                else
                searching = false
            end
            
        end    
            
    if number <= 69 && number >= 65
            say "You are a fool.  Your broke ass doesn't get channel #{number}"
    else
        say "Here is what's playing on channel #{number}:"
        
        object = SiriAddViews.new
            
        object.make_root(last_ref_id)
            
        
        
        if show['programDescription'].nil?
            
            answer = SiriAnswer.new("Now Playing: ", [SiriAnswerLine.new('logo', self.image_prefix + channel_id + '.png'),
                                    SiriAnswerLine.new(show['title'])])
            else
            answer = SiriAnswer.new("Now Playing: ", [SiriAnswerLine.new('logo', self.image_prefix + channel_id + '.png'),
                                    SiriAnswerLine.new(show['title']), SiriAnswerLine.new(show['programDescription'])])
        end
            
        object.views << SiriAnswerSnippet.new([answer])
            
        send_object object
            
        response = ask "Would you like to watch #{show['title']}"
        
        if (response =~ /yes/i)
            
            change_channel(number)
            
            else
                response = ask "Should I check another channel?"
                    if (response =~ /yes/i)
                            
                            number = ask "Which channel?"
                            number = number.to_i
                            channelCheck(number)
                     else
                            say "Good choice."
                    end
        end
    end
        request_completed
    end

    def change_channel(number)
    x = 0
    say "I'm changing the channel to #{number}."
    
    chan_str = number.to_s.split('')
    base = "#{self.ip}:9080/xml/"
    
    response = HTTParty.get("#{base}login?un=mce&pw=8u88aD0g")
    
    tokens = response["loginresponse"]
    tokens = tokens["token"]
    tokens = tokens.to_s
    
    if chan_str.length > 1
        while  x < chan_str.length
            uri = URI("#{base}sendremotekey/Num#{chan_str[x]}?token=#{tokens}") 
            
            #print chan_str.length
            
            Net::HTTP.start(uri.host, uri.port) do |http|
                request = Net::HTTP::Get.new uri.request_uri
                response = http.request request# Net::HTTPResponse object
                
            end
            x = x+1
        end
        else
        
        uri = URI("#{base}sendremotekey/Num#{chan_str[0]}?token=#{tokens}")
        
        Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Get.new uri.request_uri
            response = http.request request# Net::HTTPResponse object
        end
    end
    
    
    request_completed 
    
    
    
end

def controls(var)
    
    
    if var == "tv" 
        say "Turning on Live Tv."
        commands("GoToLiveTV")
    end
    if var == "menu"
        say "Going to main menu"
        commands("Menu")
    end
    if var == "music"
        say "Playing some kick-ass rock."
    command = ["GoToMusic", "NavRight", "NavRight", "NavDown", "Play" ]
        x = 0
        while x< command.length
            commands(command[x])
            x = x + 1
        end
      end
    if var == "stop"
        commands("Stop")
    end
    if var == "skip"
        say "Skipping forward"
        commands("SkipFwd")
    end
    if var == "previous"
        say "Skipping back"
        commands("SkipBack")
    end
end

def commands(command)
        
        
        base = "#{self.ip}:9080/xml/"
        
        response = HTTParty.get("#{base}login?un=mce&pw=8u88aD0g")
        
        tokens = response["loginresponse"]
        tokens = tokens["token"]
        tokens = tokens.to_s
        
        uri = URI("#{base}sendremotekey/#{command}?token=#{tokens}")
        
        Net::HTTP.start(uri.host, uri.port) do |http|
            request = Net::HTTP::Get.new uri.request_uri
            response = http.request request# Net::HTTPResponse object
        end
        
        


request_completed 
end
    
end
