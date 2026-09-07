class ClientLeadsController < ApplicationController
  before_action :set_client_lead, only: [:show, :edit, :update, :destroy]
  before_action -> { authorize!(:manage_all_records) }, only: [:new, :create, :destroy]
  before_action :authorize_lead_access!, only: [:show, :edit, :update]
  before_action -> { authorize!(:edit_own_leads) }, only: [:edit, :update]

  def index
    @client_leads = scoped_client_leads.includes(:assignee).order(created_at: :desc)
    @client_leads = @client_leads.where(status: params[:status]) if params[:status].present?
  end

  def show
  end

  def new
    @client_lead = ClientLead.new
  end

  def create
    @client_lead = ClientLead.new(client_lead_params)
    if @client_lead.save
      redirect_to client_leads_path, notice: "Lead added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @client_lead.update(client_lead_params)
      redirect_to client_leads_path, notice: "Lead updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client_lead.destroy
    redirect_to client_leads_path, notice: "Lead removed."
  end

  private

  def set_client_lead
    @client_lead = ClientLead.find(params[:id])
  end

  def authorize_lead_access!
    authorize_record!(@client_lead)
  end

  def client_lead_params
    if can?(:manage_all_records)
      params.require(:client_lead).permit(:client_name, :assignee_id, :calls, :tests, :status, :rounds, :remarks)
    else
      params.require(:client_lead).permit(:calls, :tests, :status, :rounds, :remarks)
    end
  end
end
