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
  
end
