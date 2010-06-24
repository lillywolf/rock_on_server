class CreatureGroupController < ApplicationController
  
  def get_all 
    @response = CreatureGroup.all
    render :json => @response.to_json    
  end
  
  def find_by_user_id
    @array = Array.new
    CreatureGroup.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |creature_group|
      hash = Hash.new
      user_reference = creature_group.user_id
      owned_dwelling_reference = creature_group.owned_dwelling_id       
      hash["belongs_to"] = ["user", "owned_dwelling"]
      hash["belongs_to_id"] = [user_reference, owned_dwelling_reference]
      hash["instance"] = creature_group
      @array.push hash            
    end            
    render :json => @array.to_json         
  end  
  
end
