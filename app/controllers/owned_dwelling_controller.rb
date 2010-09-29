class OwnedDwellingController < ApplicationController

  def find_by_user_id
    @array = Array.new
    OwnedDwelling.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_dwelling|
      hash = Hash.new
      user_reference = owned_dwelling.user_id
      dwelling_reference = owned_dwelling.dwelling_id       
      hash["belongs_to"] = ["user", "dwelling"]
      hash["belongs_to_id"] = [user_reference, dwelling_reference]
      hash["instance"] = owned_dwelling
      @array.push hash            
    end            
    render :json => @array.to_json         
  end  
  
  def update_state
    array = Array.new
    hash = Hash.new

    owned_dwelling = OwnedDwelling.find(params[:id])    
    owned_dwelling.validate_state_change(params[:time_elapsed_client], params[:show_button_clicked])
    owned_dwelling.save
    
    hash["instance"] = owned_dwelling
    hash["already_loaded"] = true
    hash["model"] = "owned_dwelling"
    hash["method"] = "update_state"
    array.push hash
    render :json => array.to_json    
  end
    
  def update_fancount
    array = Array.new
    hash = Hash.new
    
    owned_dwelling = OwnedDwelling.find(params[:id])
    owned_structure = OwnedStructure.find(params[:owned_structure_id])

    if owned_structure.validate_usage_complete(array)
      # owned_dwelling.update_boothcount(params[:to_add].to_i, array)
      # owned_dwelling.update_fancount(params[:to_add].to_i)
      owned_dwelling.validate_state_change(nil, false)
    end  
    owned_dwelling.save

    hash["instance"] = owned_dwelling
    hash["already_loaded"] = true
    hash["model"] = "owned_dwelling"
    hash["method"] = "update_fancount"
    array.push hash
    render :json => array.to_json    
  end  
  
  def change_venue
    array = Array.new
    hash = Hash.new
    
    owned_dwelling = OwnedDwelling.find(params[:id])
    owned_dwelling.switch_dwelling_id(params[:level])
    
    hash["instance"] = owned_dwelling
    hash["already_loaded"] = true
    hash["model"] = "owned_dwelling"
    hash["method"] = "change_venue"
    array.push hash
    render :json => array.to_json    
  end  
  
end
