class OwnedUsableController < ApplicationController

  def find_by_user_id
    @array = Array.new
    OwnedUsable.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_usable|
      hash = Hash.new
      usable_reference = owned_usable.usable_id 
      user_reference = owned_usable.user_id
      hash["belongs_to"] = ["user", "usable"]
      hash["belongs_to_id"] = [user_reference, usable_reference]
      hash["instance"] = owned_usable
      @array.push hash            
    end            
    render :json => @array.to_json         
  end


end
