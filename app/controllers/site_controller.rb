# require 'vendor/plugins/facebooker/lib/facebooker/rails/controller.rb'
class SiteController < ApplicationController
  
  # skip_before_filter :verify_session, :only => :get_static_content
  # skip_before_filter :set_user, :only => :get_static_content
  # 
  # def get_static_content
  # end  
  
  before_filter :set_facebook_session
  helper_method :facebook_session  
  
  # layout nil

  def index
    
    ensure_application_is_installed_by_facebook_user    
    user = setup_facebook_user
    if user.nil?
      render :text => 'Where are you?'
    else
      friends = user.friends
      friends.each do |f|
        # render :text => 'hi'
      end  
    end    
    
    # # attempt to create a facebook session
    # fb_session = create_facebook_session
    # 
    # @source_link_id = params[:source_link_id] || params[:source]
    # @referrer_id = params[:referrer_id]
    # 
    # if fb_session.nil?
    #   # Player has not authorized the application
    #   top_redirect_to "http://www.facebook.com/login.php?v=1.0&api_key=#{FB_CONFIGURATION['api_key']}&canvas=&next=?source_link_id=#{@source_link_id}&referrer_id=#{@referrer_id}"
    # else
    #   # Retrieve the users facebook id from the facebook session
    #   snid = fb_session.user.id
    # 
    #   user = User.find_or_create_by_snid( snid, @source_link_id )
    #   if user.nil?
    #     render :text => 'The Game is down for maintenance.'
    #     return
    #   end

      # Create a 'session' in memcached for this user to do later authentication
      # secret = User.new_secret(24)
      # CACHE.set( user.session_key, secret, 4.hours )

      # Store the user's facebook session in memcached so that we can make API calls to facebook later on
      # CACHE.set( user.fb_session_key, fb_session, 15.minutes )

      # prepare variables for the view
      # @swf_iframe_url = "#{FB_CONFIGURATION['callback_url']}/site/home?uid=#{user.id}&secret=#{secret}"
      @swf_iframe_url = "http://localhost:3000/main.swf"
    # end

  end
  
  def setup_facebook_user
      @current_facebook_user = facebook_session.user
      return @current_facebook_user
  end  
  
  def get_facebook_friend_data
    array = Array.new
    user = setup_facebook_user  
    # if ( user.name rescue false )
      friends = user.friends
      # friends.each do |f|
        # hash = Hash.new
        # hash["name"] = f.name
        # array.push hash  
      # end      
    # else
    # end
    render :json => array.to_json        
  end  


  # def uninstall
  #   create_facebook_session if RAILS_ENV=='production'
  #   @user = User.actually_find_by_snid( fb_user_id ) 
  #   @user.destroy
  #   render :text => "destroyed"
  # end
  # 
  # def home
  #   @uid = params[:uid]
  #   @secret = params[:secret]
  # end
  # 
  # @@down = false
  # def health_check
  #   if ( params[:down] == 'true' )
  #     @@down = true
  #   elsif ( params[:down] == 'false' )
  #     @@down = false
  #   end
  # 
  #   if ( @@down )
  #     raise '@@down is true'
  #   end
  #   render :text => 'ok'
  # end
  # 
  # def invite
  # 
  # end
  # 
  # def invite_complete
  # end    
  
end
