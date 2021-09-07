class AgendasController < ApplicationController
  before_action :set_agenda, only: %i[destroy] #show edit update]

  def index
    @agendas = Agenda.all
  end

  def new
    @team = Team.friendly.find(params[:team_id])
    @agenda = Agenda.new
  end

  def create
    @agenda = current_user.agendas.build(title: params[:title])
    @agenda.team = Team.friendly.find(params[:team_id])
    current_user.keep_team_id = @agenda.team.id
    if current_user.save && @agenda.save
      redirect_to dashboard_url, notice: I18n.t('views.messages.create_agenda')
    else
      render :new
    end
  end
  def destroy
    if @agenda.team.owner_id == current_user.id
      @agenda.destroy
      @agenda.team.members.each do |member|
        AgendaMailer.agenda_mail(member.email, @agenda).deliver
      end
      redirect_to dashboard_url, notice: "#{@agenda.title} was successfully deleted"
    else
      redirect_to team_url(@agenda.team_id), notice: I18n.t(%(You don't have an authority to delete agendas))
    end
  end

  private

  def set_agenda
    @agenda = Agenda.find(params[:id])
  end

  def agenda_params
    params.fetch(:agenda, {}).permit %i[title description]
  end
end
