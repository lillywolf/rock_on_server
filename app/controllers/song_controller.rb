class SongController < ApplicationController
require "right_aws"
require "rubygems"
require "base64"
require "aws/s3"

  def get_all
    array = Array.new
    Song.find_each do |song|
      hash = Hash.new
      hash["model"] = "song"
      hash["instance"] = song
      array.push hash
    end  
    render :json => array.to_json    
  end
  
  def get_song
    array = Array.new
    song = Song.find(params[:id])
    s3 = AWS::S3::Base.establish_connection!(
       :access_key_id     => 'AKIAIR46365NFZLQ5QUA',
       :secret_access_key => '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'
     )    
    mp3 = File.new("song_data.mp3", "w")
    instance = Hash.new        
    i = 0  
    File.open("song_data.mp3", "w") do |f|
      AWS::S3::S3Object.stream(song.url, "lilly_lightweight_bucket1") do |chunk|
        f.write chunk
        logger.debug(i.to_s)
        i = i + 1
      end
      instance["data"] = f      
    end    
    hash = Hash.new
    instance["title"] = song.title
    instance["id"] = song.id
    hash["model"] = "song"
    hash["instance"] = instance
    hash["already_loaded"] = true
    array.push hash
    render :json => array.to_json  
  end  

  def upload_song
    array = Array.new
    song = Song.create()
    song.url = "test1/" + params[:filename]
    s3 = Rightscale::S3.new("AKIAIR46365NFZLQ5QUA", "RtsgxayzHI7NctIrKDd3c1phXEfecoMu0UD0pXZ0")
    bucket = s3.bucket("lilly_lightweight_bucket1")
    myFile = File.new(params[:filename], "wb")
    key = Base64.decode64 params[:bytearray]
    File.open(params[:filename], "wb") do |f|
      f.write(key)
    end
    File.open(params[:filename], "r") do |f|
      bucket.key("test1" + "/" + params[:filename]).put(f.read)
    end
    song.save
    hash = Hash.new
    hash["model"] = "song"
    hash["instance"] = song
    array.push hash
    render :json => array.to_json
  end

end
