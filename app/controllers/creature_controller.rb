class CreatureController < ApplicationController
    
  def find_by_user_id
    array = Array.new
    Creature.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |creature|
      hash = Hash.new
      creature_group_reference = creature.creature_group_id
      hash["instance"] = creature
      # hash["has_many"] = ["owned_layerable"]
      hash["belongs_to"] = ["creature_group"]
      hash["belongs_to_id"] = [creature_group_reference]
      hash["model"] = "creature"
      array.push hash
    end  
    render :json => array.to_json  
  end
  
  def find_by_game_user_id
    array = Array.new
    Creature.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |creature|
      hash = Hash.new
      creature_group_reference = creature.creature_group_id
      hash["instance"] = creature
      hash["has_many"] = ["owned_layerable"]
      hash["belongs_to"] = ["creature_group"]
      hash["belongs_to_id"] = [creature_group_reference]
      hash["model"] = "creature"
      array.push hash
    end  
    render :json => array.to_json  
  end  
  
  def find_avatar_by_user_id
    array = Array.new
    Creature.find_each(:conditions => ["user_id = ? and creature_type = ?", params[:user_id], params[:creature_type]]) do |creature|
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
