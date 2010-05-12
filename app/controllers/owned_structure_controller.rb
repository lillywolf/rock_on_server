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
    @array = Array.new
    owned_structure = OwnedStructure.find(params[:id])
    owned_structure.x = params[:x]
    owned_structure.y = params[:y]
    owned_structure.z = params[:z]
    owned_structure.save
    hash = Hash.new
    hash["instance"] = owned_structure
    hash["already_loaded"] = true
    @array.push hash
    render :json => @array.to_json
  end  
  
  def create_new
    @array = Array.new
    os = OwnedStructure.create();
    os.layerable_id = params[:id]
    os.user_id = params[:user_id]
    os.save
    hash = Hash.new
    hash["instance"] = os
    hash["belongs_to"] = ["user", "structure"]
    hash["belongs_to_id"] = [os.user_id, os.structure_id]
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
    hash = Hash.new
    owned_structure = OwnedStructure.find(params[:id])
    structure = Structure.find(owned_structure.structure_id)
    user = User.find(owned_structure.user_id)    
    if owned_structure.inventory_count == 0    
      BoothStructure.find_each(:conditions => ["structure_id = ?", structure.id]) do |booth_structure|
        total_credits = booth_structure.item_price * booth_structure.inventory_capacity
        owned_structure.inventory_count = booth_structure.inventory_capacity
        owned_structure.save
        owned_structure.add_hash(array, "add_booth_credits", true)
        user.add_credits(total_credits)      
      end
    end
    hash["instance"] = user
    hash["already_loaded"] = true
    hash["model"] = "user"
    hash["method"] = "add_booth_credits"
    array.push hash    
    render :json => array.to_json    
  end     

end
