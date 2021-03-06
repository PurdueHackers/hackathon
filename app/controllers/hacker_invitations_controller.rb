class HackerInvitationsController < ApplicationController
  def new
  end

  def create
    team = Team.find(current_user.team_id)

    invitees = [params[:email_one], params[:email_two], params[:email_three]]

    invitees.each do |invitee|
      team.send_hacker_invitation(invitee, current_user) if invitee.present?
    end

    flash[:notice] = 'Invitation(s) sent.'
    redirect_to my_team_path
  end
end
