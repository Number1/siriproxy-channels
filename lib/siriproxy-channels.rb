require 'cora'
require 'siri_objects'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'httparty'
require 'json'
class SiriProxy::Plugin::Channels < SiriProxy::Plugin
    def initialize(config = {})
        #if you have custom configuration options, process them here!
    end
    
    tempo = Time.new
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
        number = "Num" + number1
        
     commands(number) 
    end
    
   listen_for /media center (tv|menu|music|stop|skip|previous)/i do |word1|
       
       word = word1
       word = word.downcase
       controls(word)
       end

    def channelCheck(number)
        
        tempo = Time.new
        
        
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
        
        channel = h[number]
        
        uri = "http://tvlistings.zap2it.com/tvlistings/ZCSGrid.do?stnNum=#{channel}&channel=#{number}"
        doc = Nokogiri::HTML(open(uri))
        
        
        channel1 = doc.css("h1").map do |status|
            status.text.strip
        end
        
       program = doc.css('a[id="rowTitle1"]').map do |prog1|
            prog1.text.strip
        end
        episode = doc.css('li[id="row1-1"] a[class="zc-ssl-pg-ep"]').map do |ep|
            ep.text.strip
        end
        
        if (tempo.min >= 30 && tempo.min <=55)
            program1=program[2]
        end
        if
            program1=program[1]
        end
        
        channel2=channel1[0]
        
        episode1 = episode[0]
        if number <= 69 && number >= 65
            say "You are a fool.  Your broke ass doesn't get #{channel2}"
        else
        say "#{program1}: #{episode1} is playing on #{channel2}, channel #{number}"
        response = ask "Would you like to watch #{program1}"
        if (response =~ /yes/i)
            change_channel(number)
            
            
            else
            say "That is some bullshit"
        end
        end
        request_completed
    end
def change_channel(number)
    x = 0
    say "I'm changing the channel to #{number}."
    
    chan_str = number.to_s.split('')
    base = "http://192.168.0.3:9080/xml/"
    
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
        
        
        base = "http://192.168.0.3:9080/xml/"
        
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
