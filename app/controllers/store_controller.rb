class StoreController < ApplicationController

  def find_by_parent_id
    array = Array.new    
    Store.find_each(:conditions => ["game_id = ?", params[:game_id]]) do |store|
      hash = Hash.new          
      hash["instance"] = store
      hash["has_many"] = ["store_owned_thinger"]
      hash["model"] = "store"      
      array.push hash   
    end 
    render :json => array.to_json  
  end
  
  def get_all
    array = Array.new    
    Store.find_each do |store|
      hash = Hash.new          
      hash["instance"] = store
      hash["has_many"] = ["store_owned_thinger"]
      hash["model"] = "store"      
      array.push hash   
    end 
    render :json => array.to_json  
  end  
  
end
