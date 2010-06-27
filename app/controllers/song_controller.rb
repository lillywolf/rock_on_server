class SongController < ApplicationController

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

end
