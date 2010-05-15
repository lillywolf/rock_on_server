class OwnedStructureController < ApplicationController

  def find_by_user_id
    @array = Array.new
    OwnedStructure.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_structure|
      hash = Hash.new
      structure_reference = owned_structure.structure_id 
      user_reference = owned_structure.user_id
      owned_structure.do_type_specific_updates
      hash["belongs_to"] = ["user", "structure"]
      hash["belongs_to_id"] = [user_reference, structure_reference]
      hash["instance"] = owned_structure
      @array.push hash            
    end            
    render :json => @array.to_json         
  end
  
  def save_placement
    array = Array.new
    owned_structure = OwnedStructure.find(params[:id])
    owned_structure.save_new_placement(params[:x], params[:y], params[:z])
    owned_structure.save
    owned_structure.add_hash(array, "save_placement", true)
    render :json => array.to_json
  end  
  
  def create_new
    @array = Array.new
    os = OwnedStructure.create();
    os.structure_id = params[:structure_id]
    os.owned_dwelling_id = params[:owned_dwelling_id]
    os.user_id = params[:user_id]
    os.save_new_placement(params[:x], params[:y], params[:z])
    os.in_use = true
    os.do_type_specific_creation
    os.save
    hash = Hash.new
    hash["instance"] = os
    hash["belongs_to"] = ["user", "structure"]
    hash["belongs_to_id"] = [os.user_id, os.structure_id]
    hash["method"] = "create_new"
    hash["model"] = "owned_structure"
    @array.push hash
    render :json => @array.to_json
  end 
  
  def update_inventory_count
    @array = Array.new
    owned_structure = OwnedStructure.find(params[:id])
    owned_dwelling = OwnedDwelling.find(owned_structure.owned_dwelling_id)
    owned_structure.update_inventory_count(owned_dwelling)
    
    if params[:client_validate] == "true"
      owned_structure.validate_inventory_count_zero
    end    
    
    hash = Hash.new
    hash["instance"] = owned_structure
    hash["already_loaded"] = true
    hash["model"] = "owned_structure"
    hash["method"] = "update_inventory_count" 
    @array.push hash
    render :json => @array.to_json       
  end  
  
  def decrement_inventory
    array = Array.new
    hash = Hash.new
    os = OwnedStructure.find(params[:id])
    os.inventory_count = os.inventory_count - params[:to_decrease].to_i
    os.save
    hash["instance"] = os
    hash["already_loaded"] = true
    hash["model"] = "owned_structure"
    array.push hash
    render :json => array.to_json
  end
  
  def add_booth_credits
    array = Array.new
    total_credits = 0
    total_xp = 0
    owned_structure = OwnedStructure.find(params[:id])
    structure = Structure.find(owned_structure.structure_id)
    user = User.find(owned_structure.user_id)    
    if owned_structure.inventory_count == 0    
      BoothStructure.find_each(:conditions => ["structure_id = ?", structure.id]) do |booth_structure|
        total_credits += booth_structure.item_price * booth_structure.inventory_capacity
        total_xp += booth_structure.item_price * booth_structure.inventory_capacity * booth_structure.getBoothCreditsMultiplier
        owned_structure.inventory_count = booth_structure.inventory_capacity
        owned_structure.save
        owned_structure.add_hash(array, "add_booth_credits", true)
      end
      user.add_credits(total_credits)
      user.add_xp(total_xp)
      logger.debug(user.level_id.to_s)
      user.add_hash(array, "add_booth_credits", true)
    end
    render :json => array.to_json    
  end 
  
  def add_station_credits
    array = Array.new
    owned_structure = OwnedStructure.find(params[:id])
    structure = Structure.find(owned_structure.structure_id)
    user = User.find(owned_structure.user_id)
    user.add_credts(structure.capacity * structure.getListenerCredits)
    user.add_xp(structure.capacity * structure.getListenerCredits * structure.getStationCreditsMultiplier)
    user.save
    user.add_hash
    render :json => array.to_json        
  end
    
end
