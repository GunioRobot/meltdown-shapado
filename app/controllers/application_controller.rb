# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Rack::Recaptcha::Helpers
  include Subdomains
  include Sweepers

  include Shapado::Controllers::Access
  include Shapado::Controllers::Routes
  include Shapado::Controllers::Locale
  include Shapado::Controllers::Utils

  if !AppConfig.recaptcha['activate']
    def recaptcha_valid?
      true
    end
  end

  protect_from_forgery

  before_filter :find_group
  before_filter :check_group_access
  before_filter :set_locale
  before_filter :find_languages
  before_filter :share_variables
  layout :set_layout

  helper_method :recaptcha_tag

  rescue_from Error404, :with => :render_404
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404

  protected
  def find_group
    @current_group ||= begin
      subdomains = request.subdomains
      subdomains.delete("www") if request.host == "www.#{AppConfig.domain}"
      _current_group = Group.where({:state => "active", :domain => request.host}).first
      unless _current_group
        if subdomain = subdomains.first
          _current_group = Group.where(:state => "active", :subdomain => subdomain).first
          unless _current_group.nil?
            redirect_to domain_url(:custom => _current_group.domain)
            return
          end
        end
        flash[:warn] = t("global.group_not_found", :url => request.host)
        redirect_to domain_url(:custom => AppConfig.domain)
        return
      end
      _current_group
    end
    @current_group
  end

  def find_questions(extra_conditions = {}, extra_scope = { }, is_root_page = nil)
    if params[:language] || request.query_string =~ /tags=/
      params.delete(:language)
      head :moved_permanently, :location => url_for(params)
      return
    end

    conditions = scoped_conditions(:banned => false)

    if params[:sort] == "popularne"
      conditions[:activity_at] = {"$gt" => 7.days.ago}
    end

    @active_tab = :questions
    if is_root_page
      @active_tab = :root
      params[:page] = nil
      set_page_title(nil)
    else
      set_page_title(t("questions.index.title"))
    end

    @active_subtab ||= params[:sort] || "najnowsze"

    if @active_subtab == "bez_odpowiedzi"
      conditions[:answered_with_id] = nil
      conditions[:answers_count] = 0
    end

    @questions = Question.minimal.where(conditions.merge(extra_conditions)).order_by(current_order)

    extra_scope.keys.each do |key|
      @questions = @questions.send(key, extra_scope[key])
    end

    @questions = @questions.paginate({:per_page => 25, :page => params[:page] || 1})

    @langs_conds = scoped_conditions[:language][:$in]

    if logged_in?
      feed_params = { :feed_token => current_user.feed_token }
    else
      feed_params = {  :lang => I18n.locale,
                          :mylangs => current_languages }
    end
    add_feeds_url(url_for({:format => "atom"}.merge(feed_params)), t("feeds.questions"))
    if params[:tags]
      add_feeds_url(url_for({:format => "atom", :tags => params[:tags]}.merge(feed_params)),
                    "#{t("feeds.tag")} #{params[:tags].inspect}")
    end
    @tag_cloud = Question.tag_cloud(scoped_conditions, 25)

    respond_to do |format|
      format.html
      format.mobile
      format.json  { render :json => @questions.to_json(:except => %w[_keywords watchers slugs]) }
      format.atom
    end
  end

  def find_activities(conds = {})
    #add_feeds_url(url_for({:format => "atom"}.merge(feed_params)), t("feeds.questions"))

    @activities = current_group.activities.where(conds).order(:created_at.desc).
                                paginate(:page => params[:page],
                                         :per_page => params[:per_page]||25)

    respond_to do |format|
      format.html
      format.json { render :json => @activities}
    end
  end

  def current_group
    @current_group
  end
  helper_method :current_group

  def scoped_conditions(conditions = {})
    unless current_tags.empty?
      conditions.deep_merge!({:tags => {:$all => current_tags}})
    end
    conditions.deep_merge!({:group_id => current_group.id})
    conditions.deep_merge!(language_conditions)
    conditions
  end
  helper_method :scoped_conditions

  def set_layout
    if devise_controller? || (action_name == "new" && controller_name == "users")
      'sessions'
    elsif params["format"] == "mobile"
      'mobile'
    else
      'application'
    end
  end

  def render_404
    Rails.logger.info "ROUTE NOT FOUND (404): #{request.url}"

    respond_to do |format|
      format.html { render "public_errors/not_found", :status => '404 Not Found' }
      format.json { render :json => {:success => false, :message => "Not Found"}, :status => '404 Not Found' }
    end
  end

  # override from devise
  def after_sign_out_path_for(resource)
    params[:format] == "mobile" ? "/mobile" : root_path
  end

  def after_sign_in_path_for(resource_or_scope)
    self.current_user = resource_or_scope
    super(resource_or_scope)
  end

  def share_variables
    Thread.current[:current_group] = current_group
    Thread.current[:current_user] = current_user
    Thread.current[:current_ip] = request.remote_ip
  end
end
