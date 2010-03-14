class ThingerController < ApplicationController
  def get_all
    array = Array.new
    Thinger.find_each do |thinger|
      hash = Hash.new
      hash["model"] = "thinger"
      hash["instance"] = thinger
      array.push hash
    end  
    render :json => array.to_json    
  end
end
