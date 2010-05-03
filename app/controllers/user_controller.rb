class UserController < ApplicationController
  
  def find_by_snid
    array = Array.new    
    hash = Hash.new    
    user = User.first(:conditions => ["snid = ?", params[:snid]]) 
    level_reference = user.level_id   
    hash["instance"] = user
    hash["has_many"] = ["owned_structure", "owned_layerable", "creature", "owned_dwelling"]
    hash["belongs_to"] = ["level"]
    hash["belongs_to_id"] = [level_reference]
    hash["model"] = "user"
    array.push hash    
    render :json => array.to_json  
  end  
  
  def find_by_id
    array = Array.new    
    hash = Hash.new    
    user = User.find(params[:id])
    hash["instance"] = user
    hash["has_many"] = ["owned_structure", "owned_layerable", "creature", "owned_dwelling"]
    hash["model"] = "user"
    array.push hash    
    render :json => array.to_json  
  end  
  
  def add_credits
    array = Array.new
    hash = Hash.new
    user = User.find(params[:id])
    user.credits += params[:to_add].to_i
    user.save
    hash["instance"] = user
    hash["already_loaded"] = true
    hash["model"] = "user"
    array.push hash
    render :json => array.to_json
  end  
  
end
