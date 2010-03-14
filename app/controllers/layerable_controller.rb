class LayerableController < ApplicationController  
  
  def get_all
    array = Array.new
    Layerable.find_each do |layerable|
      hash = Hash.new
      hash["model"] = "layerable"
      hash["instance"] = layerable
      array.push hash
    end  
    render :json => array.to_json    
  end 
  
  def find_by_id_with_owner
    array = Array.new
    layerable = Layerable.find(params[:id])
    hash = Hash.new
    hash["belongs_to_id"] = params[:parent_id]
    hash["belongs_to"] = "store"
    hash["instance"] = layerable
    hash["model"] = "layerable"
    array.push hash    
    render :json => array.to_json  
  end    
  
end
