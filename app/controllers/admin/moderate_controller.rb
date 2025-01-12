class Admin::ModerateController < ApplicationController
  before_filter :login_required
  before_filter :moderator_required

  def index
    @active_subtab = params.fetch(:tab, "retag")

    options = {:banned => false,
               :group_id => current_group.id,}


    case @active_subtab
      when "flagged_questions"
        @questions = Question.where(options.merge(:flags_count.gt => 0)).
                              order_by("flags_count desc").
                              paginate(:per_page => params[:per_page] || 25,
                                                     :page => params[:questions_page] || 1)
      when "flagged_answers"
        @answers = Answer.where(options.merge(:flags_count.gt => 0)).
                          order_by("flags_count desc").
                          paginate(:per_page => params[:per_page] || 25,
                                   :page => params[:questions_page] || 1)
      when "banned"
        @banned = Question.where(options.merge(:banned => true)).
                           paginate(:per_page => params[:per_page] || 25,
                                    :page => params[:questions_page] || 1)
      when "retag"
        @questions = Question.where(options.merge(:tags => {:$size => 0})).
                              paginate(:per_page => params[:per_page] || 25,
                                       :page => params[:questions_page] || 1)
    end
  end

  def ban
    Question.ban(params[:question_ids] || [])
    Answer.ban(params[:answer_ids] || [])

    respond_to do |format|
      format.html{redirect_to :action => "index"}
    end
  end

  def unban
    Question.unban(params[:question_ids] || [])

    respond_to do |format|
      format.html{redirect_to :action => "index"}
    end
  end

end

