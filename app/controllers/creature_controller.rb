class CreatureController < ApplicationController
  require "active_support"
  require "date"
  require "time"
    
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
  
  def add_new
    @array = Array.new
    c = Creature.create()
    c.user_id = params[:user_id].to_i
    c.creature_type = params[:creature_type]
    c.last_nurture = c.created_at
    if params[:reference_id]
      c.reference_id = params[:reference_id].to_i
    end  
    c.save
    hash = Hash.new
    hash["instance"] = c
    hash["belongs_to"] = ["user"]
    hash["belongs_to_id"] = [c.user_id]
    hash["created_from_client"] = true
    hash["method"] = "add_new"
    hash["model"] = "creature"
    @array.push hash
    render :json => @array.to_json    
  end      
  
  def creature_nurture_bonus
    array = Array.new
    c = Creature.find(params[:id])
    if c.last_nurture
      gap = Time.now - Time.parse(c.last_nurture.to_s)
      logger.debug("gap: " + gap.to_s)  
      if gap < 120
        user = User.find(c.user_id)      
        user.add_bonus(params[:amount], params[:amount_type])
        user.add_hash(array, "creature_nurture_bonus", true)                
      end
    end  
    render :json => array.to_json  
  end  
  
  def creature_nurture_collection
    array = Array.new
    render :json => array.to_json
  end  
  
  def remove_from_user
    c = Creature.find(params[:id])
    c.destroy
  end  
  
  def get_all 
    @response = Creature.all
    render :json => @response.to_json    
  end  
  
  def <=> value
    return self.id.downcase <=> value.id.downcase
  end  
  
end
