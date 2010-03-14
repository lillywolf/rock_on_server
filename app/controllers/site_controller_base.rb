class SiteControllerBase < ApplicationController
  layout nil

  def index
    # attempt to create a facebook session
    fb_session = create_facebook_session
    
    @source_link_id = params[:source_link_id] || params[:source]
    @referrer_id = params[:referrer_id]
    
    if fb_session.nil?
      # Player has not authorized the application
      top_redirect_to "http://www.facebook.com/login.php?v=1.0&api_key=#{FB_CONFIGURATION['api_key']}&canvas=&next=?source_link_id=#{@source_link_id}&referrer_id=#{@referrer_id}"
    else
      # Retrieve the users facebook id from the facebook session
      snid = fb_session.user.id
      
      user = User.find_or_create_by_snid( snid, @source_link_id )
      if user.nil?
        render :text => 'The Game is down for maintenance.'
        return
      end

      # Create a 'session' in memcached for this user to do later authentication
      secret = User.new_secret(24)
      CACHE.set( user.session_key, secret, 4.hours )
      
      # Store the user's facebook session in memcached so that we can make API calls to facebook later on
      CACHE.set( user.fb_session_key, fb_session, 15.minutes )
      
      # prepare variables for the view
      @swf_iframe_url = "#{FB_CONFIGURATION['callback_url']}/site/home?uid=#{user.id}&secret=#{secret}"
    end

  end
  
  
  def uninstall
    create_facebook_session if RAILS_ENV=='production'
    @user = User.actually_find_by_snid( fb_user_id ) 
    @user.destroy
    render :text => "destroyed"
  end
  
  def home
    @uid = params[:uid]
    @secret = params[:secret]
  end
  
  @@down = false
  def health_check
    if ( params[:down] == 'true' )
      @@down = true
    elsif ( params[:down] == 'false' )
      @@down = false
    end
    
    if ( @@down )
      raise '@@down is true'
    end
    render :text => 'ok'
  end
  
  def invite
    
  end
  
  def invite_complete
  end  
end
