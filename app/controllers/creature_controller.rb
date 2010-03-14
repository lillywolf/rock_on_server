class CreatureController < ApplicationController
    
  def find_by_user_id
    array = Array.new
    Creature.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |creature|
      hash = Hash.new
      hash["instance"] = creature
      hash["has_many"] = ["owned_layerable"]
      hash["model"] = "creature"
      array.push hash
    end  
    render :json => array.to_json  
  end  
  
  def get_all 
    @response = Creature.all
    render :json => @response.to_json    
  end  
  
  def <=> value
    return self.id.downcase <=> value.id.downcase
  end  
  
end
