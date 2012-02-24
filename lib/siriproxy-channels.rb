require 'cora'
require 'siri_objects'
require 'nokogiri'
require 'open-uri'
require 'pp'

class SiriProxy::Plugin::Channels < SiriProxy::Plugin
    def initialize(config = {})
        #if you have custom configuration options, process them here!
    end
    
    tempo = Time.new
    number = 0
    word = ""
    listen_for /on (fox news|history|"true" tv)/i do |word1|
    #say "Checking for what's playing #{word1}"
    word = word1
    word = word.downcase
    
    if (word == "fox news")
        number = 38
    elsif (word == "history")
        number = 48
    elsif (word == "tru tv")
            number = 40
    else
        say "Sorry, I did not recognize your request"
    end
        
    channelCheck(number)
    
    end 

    listen_for /on channel ([0-9,]*[0-9])/i do |number1|
    say "Checking for what's playing on channel #{number1}"
    number = number1.to_i
    channelCheck(number)
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
        
#       program = doc.css('a[id="rowTitle1"]').map do |prog1|
            prog1.text.strip
        end
       episode = doc.css('li[id="row1-1"]').map do |ep|
            ep.text.strip
        end
        
      =begin  if (tempo.min >= 30 && tempo.min <=55)
            program1=program[2]
        end
        if
            program1=program[1]
        end
        =end
        channel2=channel1[0]
        show = episode[1]
        epi_sode = episode[2]

        say "#{show}: #{epi_sode} is playing on #{channel2}"
        request_completed
    end
    
end
