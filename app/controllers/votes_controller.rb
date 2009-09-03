class VotesController < ApplicationController
  before_filter :login_required

  def create
    vote = Vote.new
    if params[:vote_up]
      vote.value = 1
    elsif params[:vote_down]
      vote.value = -1
    end
    vote.voteable_type = params[:voteable_type]
    vote.voteable_id = params[:voteable_id]
    vote.user = current_user

    voted = false

    if vote.save
      vote.voteable.add_vote!(vote.value, current_user)
      voted = true
    else
      flash[:error] = vote.errors.full_messages.join(", ")
    end


    respond_to do |format|
      format.html{redirect_to params[:source]}

      format.json do
        if voted
          render(:json => {:status => :ok,
                           :average =>vote.voteable.votes_average+(vote.value)}.to_json)
        else
          render(:json => {:status => :error, :message => flash[:error] }.to_json)
        end
      end

    end
  end
end
