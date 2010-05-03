class LevelController < ApplicationController
  
  def find_by_id
    array = Array.new
    Level.find(params[:level_id]) do |level|
      hash = Hash.new
      hash["model"] = "level"
      hash["instance"] = level
      array.push hash
    end  
    render :json => array.to_json    
  end
  
  def get_all
    array = Array.new    
    Level.find_each do |level|
      hash = Hash.new          
      hash["instance"] = level
      hash["model"] = "level"      
      array.push hash   
    end 
    render :json => array.to_json  
  end  
  
end
