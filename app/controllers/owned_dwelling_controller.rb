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
  
end
