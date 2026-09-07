class ProjectBillingsController < ApplicationController
  before_action :set_project
  before_action :authorize_project_access!
  before_action :set_billing, only: [:edit, :update, :destroy, :clear, :reopen, :submit]
  before_action -> { authorize!(:manage_billings) }, only: [:new, :create, :destroy]
  before_action :authorize_billing_edit!, only: [:edit, :update, :clear, :reopen, :submit]

  def index
    @project.ensure_billing_periods! if can?(:manage_billings) && @project.start_date.present?
    @billings = @project.project_billings.ordered
    @summary = @project.billing_summary
  end

  def new
    @billing = @project.project_billings.new(
      billing_month: Date.current.beginning_of_month,
      status: :draft,
      amount: @project.fixed_price? ? @project.fixed_amount : nil
    )
  end

  def create
    @billing = @project.project_billings.new(billing_params)
    if @billing.save
      redirect_to project_project_billings_path(@project), notice: "Billing entry added for #{@billing.month_label}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @billing.update(billing_params)
      redirect_to project_project_billings_path(@project), notice: "Billing updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @billing.destroy
    redirect_to project_project_billings_path(@project), notice: "Billing entry removed."
  end

  def clear
    @billing.update!(status: :cleared)
    redirect_to project_project_billings_path(@project), notice: "#{@billing.month_label} marked cleared."
  end

  def reopen
    @billing.update!(status: :pending)
    redirect_to project_project_billings_path(@project), notice: "#{@billing.month_label} marked pending."
  end

  def submit
    @billing.update!(status: :pending)
    redirect_to project_project_billings_path(@project), notice: "#{@billing.month_label} submitted as pending."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_billing
    @billing = @project.project_billings.find(params[:id])
  end

  def authorize_project_access!
    authorize_record!(@project)
  end

  def authorize_billing_edit!
    return if can?(:manage_billings)
    return if can?(:edit_own_projects) && owns_record?(@project)

    redirect_to root_path, alert: "You do not have permission to do that."
  end

  def billing_params
    params.require(:project_billing).permit(:billing_month, :hours_billed, :amount, :status, :notes)
  end
end
