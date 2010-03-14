class StoreOwnedThingerController < ApplicationController

  def find_by_store_id
    array = Array.new    
    StoreOwnedThinger.find_each(:conditions => ["store_id = ?", params[:store_id]]) do |store_owned_thinger|
      hash = Hash.new          
      hash["instance"] = store_owned_thinger
      hash["model"] = "store_owned_thinger"
      hash["belongs_to"] = ["store", store_owned_thinger.thinger_type]
      hash["belongs_to_id"] = [store_owned_thinger.store_id, store_owned_thinger.thinger_id] 
      array.push hash   
    end 
    render :json => array.to_json  
  end
  
end
