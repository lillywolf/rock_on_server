class OwnedStructureController < ApplicationController

  def find_by_user_id
    @array = Array.new
    OwnedStructure.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_structure|
      hash = Hash.new
      structure_reference = owned_structure.structure_id 
      user_reference = owned_structure.user_id
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
  
  def decrement_inventory
    array = Array.new
    hash = Hash.new
    os = OwnedStructure.find(params[:id])
    os.inventory_count = os.inventory_count - 1;
    os.save
    hash["instance"] = os
    hash["already_loaded"] = true
    hash["model"] = "owned_structured"
    array.push hash
    render :json => array.to_json
  end   

end
