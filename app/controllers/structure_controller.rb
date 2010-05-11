class StructureController < ApplicationController

  def get_all
    array = Array.new
    Structure.find_each do |structure|
      hash = Hash.new
      hash["model"] = "structure"
      hash["instance"] = structure
      hash["has_many"] = ["booth_structure"]
      array.push hash
    end  
    render :json => array.to_json    
  end  
  
end
