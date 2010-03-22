class UserController < ApplicationController
  
  def find_by_id
    array = Array.new    
    hash = Hash.new    
    user = User.find(params[:id])
    hash["instance"] = user
    hash["has_many"] = ["owned_structure", "owned_layerable", "creature"]
    hash["model"] = "user"
    array.push hash    
    render :json => array.to_json  
  end  
  
  def add_credits
    array = Array.new
    hash = Hash.new
    user = User.find(params[:id])
    user.credits = user.credits + params[:to_add]
    user.save
    hash["instance"] = user
    hash["model"] = "user"
    array.push hash
    render :json => array.to_json
  end  
  
end
