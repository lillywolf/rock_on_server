class UsableController < ApplicationController

  def get_all
    array = Array.new
    Usable.find_each do |usable|
      hash = Hash.new
      hash["model"] = "usable"
      hash["instance"] = usable
      array.push hash
    end  
    render :json => array.to_json    
  end

end
