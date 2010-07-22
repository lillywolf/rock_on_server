class OwnedSongController < ApplicationController
  
  def find_by_user_id
    @array = Array.new
    OwnedSong.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_song|
      hash = Hash.new
      song_reference = owned_song.song_id 
      user_reference = owned_song.user_id
      hash["belongs_to"] = ["user", "song"]
      hash["belongs_to_id"] = [user_reference, song_reference]
      hash["instance"] = owned_song
      hash["model"] = "owned_song"
      @array.push hash            
    end            
    render :json => @array.to_json         
  end  
  
end
