class BoothStructureController < ApplicationController

  def get_all
    array = Array.new
    BoothStructure.find_each do |booth_structure|
      structure_reference = booth_structure.structure_id                   
      hash = Hash.new
      hash["model"] = "booth_structure"
      hash["instance"] = booth_structure
      hash["belongs_to"] = "structure"
      hash["belongs_to_id"] = [structure_reference]      
      array.push hash
    end  
    render :json => array.to_json    
  end
  
  def find_by_structure_id
    array = Array.new
    BoothStructure.find_each(:conditions => ["structure_id = ?", params[:structure_id]]) do |booth_structure|
      structure_reference = booth_structure.structure_id       
      hash = Hash.new
      hash["model"] = "booth_structure"
      hash["belongs_to"] = ["structure"]
      hash["belongs_to_id"] = [structure_reference]
      hash["instance"] = booth_structure
      array.push hash
    end  
    render :json => array.to_json    
  end    
  
end
