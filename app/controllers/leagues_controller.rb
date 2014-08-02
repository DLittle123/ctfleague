class LeaguesController < ApplicationController
  def new
    @league = League.new
  end

  def create
    @league = current_user.leagues.build(league_params)
    @league.season = 1
    if @league.save
      @league.memberships.create(:user => current_user, :points => 0)
      redirect_to new_league_team_path(@league), notice: "Your league has been created!"
    else
      flash[:alert] = "Your league could not be created."
      render :new
    end
  end

  def edit
    @league = League.find(params[:id])
  end

  def update
    @league = League.find_by_id(params[:id])
    if @league.update(invite_emails: params[:league][:invite_emails])
      redirect_to league_path(@league.id), notice: "Invited players to your league!"
    else
      flash[:alert] = "Your players could not be invited."
      render :new
    end
  end

  def show
    @league = League.find(params[:id])
  end

  def send_invite
    @league = League.find(params[:league_id])

    emails = params[:emails].split(',').map!{|e| e.strip}

    LeagueMailer.invite_email(emails, @league).deliver

    redirect_to league_path(@league.id), notice: "Your invites have been sent!"
  end

  def join_league
    @league = League.find(params[:league_id])
    @user = User.find(params[:user_id])

    if @league.league_key = params[:league_key]
      @team = Team.new
      @team.name = params[:team_name]
      @team.save

      @league.teams << @team
      @user.teams << @team
      @league.memberships.create(:user => @user, :points => 0)
      redirect_to league_path(@league.id)
    else
      flash[:alert] = "You have entered an incorrect League Key."
      redirect_to league_path(@league.id)
    end
  end

  def destroy
    @league = League.find(params[:id])

    #only user with permission to destroy is commissioner.
    @user = @league.commissioner

    @league.destroy

    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.xml  { head :ok }
    end
  end

  private

  def league_params
    params.require(:league).permit(:name)
  end
end
