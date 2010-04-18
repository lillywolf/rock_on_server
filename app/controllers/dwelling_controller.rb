class DwellingController < ApplicationController
  
  def get_all
    array = Array.new
    Dwelling.find_each do |dwelling|
      hash = Hash.new
      hash["model"] = "dwelling"
      hash["instance"] = dwelling
      array.push hash
    end  
    render :json => array.to_json    
  end
  
end
