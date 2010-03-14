class OwnedLayerableController < ApplicationController
  
  def find_by_creature_id
    @array = Array.new
    Creature.find_each(:conditions => ["id = ?", params[:creature_id]]) do |creature|
      @owned_layerables = creature.owned_layerables
      @owned_layerables.find_each do |owned_layerable|
        hash = Hash.new
        creature_reference = owned_layerable.creature_id
        layerable_reference = owned_layerable.layerable_id 
        user_reference = owned_layerable.user_id
        hash["belongs_to"] = ["creature", "layerable"]
        hash["belongs_to_id"] = [creature_reference, layerable_reference]
        hash["instance"] = owned_layerable
        @array.push hash            
      end 
    end            
    render :json => @array.to_json         
  end
  
  def find_by_user_id
    @array = Array.new
    OwnedLayerable.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_layerable|
      hash = Hash.new
      layerable_reference = owned_layerable.layerable_id 
      user_reference = owned_layerable.user_id
      hash["belongs_to"] = ["user", "layerable"]
      hash["belongs_to_id"] = [user_reference, layerable_reference]
      hash["instance"] = owned_layerable
      @array.push hash            
    end            
    render :json => @array.to_json         
  end  
  
  def make_in_use
    @array = Array.new
    owned_layerable = OwnedLayerable.find(params[:id])
    owned_layerable.in_use = true
    owned_layerable.save
    hash = Hash.new
    hash["instance"] = owned_layerable
    hash["already_loaded"] = true
    @array.push hash
    render :json => @array.to_json
  end
  
  def remove_from_in_use
    @array = Array.new
    owned_layerable = OwnedLayerable.find(params[:id])
    owned_layerable.in_use = false
    owned_layerable.save
    hash = Hash.new
    hash["instance"] = owned_layerable
    hash["already_loaded"] = true
    @array.push hash
    render :json => @array.to_json
  end    
  
  def create_new
    @array = Array.new
    ol = OwnedLayerable.create();
    ol.layerable_id = params[:id]
    ol.user_id = params[:user_id]
    ol.save
    hash = Hash.new
    hash["instance"] = ol
    hash["belongs_to"] = ["user", "layerable"]
    hash["belongs_to_id"] = [ol.user_id, ol.layerable_id]
    @array.push hash
    render :json => @array.to_json
  end  
  
end
