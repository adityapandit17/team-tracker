class UsersController < ApplicationController
  before_action -> { authorize!(:manage_users) }
  before_action :set_user, only: [:edit, :update, :destroy, :demote]

  def index
    @users = User.includes(:developer).order(:role, :name)
    @users = @users.where(role: params[:role]) if params[:role].present?
  end

  def new
    @user = User.new(role: :team_lead)
    @developers = Developer.left_outer_joins(:user).where(users: { id: nil }).order(:name)
  end

  def create
    @user = User.new(user_params)
    @user.password_confirmation = @user.password

    if @user.save
      @user.developer&.update!(team_lead_id: nil) if @user.team_lead?
      redirect_to accounts_path, notice: "#{@user.display_name} created as #{@user.role.humanize}."
    else
      @developers = Developer.left_outer_joins(:user).where(users: { id: nil }).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @developers = available_developers_for(@user)
  end

  def update
    attrs = user_params
    if attrs[:password].blank?
      attrs = attrs.except(:password, :password_confirmation)
    else
      attrs[:password_confirmation] = attrs[:password]
    end

    if @user.update(attrs)
      @user.developer&.update!(team_lead_id: nil) if @user.team_lead?
      redirect_to accounts_path, notice: "User updated."
    else
      @developers = available_developers_for(@user)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      return redirect_to accounts_path, alert: "You cannot delete your own account."
    end

    @user.destroy
    redirect_to accounts_path, notice: "User removed."
  end

  def demote
    unless @user.team_lead?
      return redirect_to accounts_path, alert: "Only team leads can be demoted."
    end

    lead = User.team_lead.where.not(id: @user.id).find_by(id: params[:assign_to_lead_id])
    @user.demote_to_developer!(assign_to_lead: lead)
    redirect_to accounts_path, notice: "#{@user.display_name} demoted to developer."
  rescue ArgumentError => e
    redirect_to accounts_path, alert: e.message
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def available_developers_for(user)
    Developer.left_outer_joins(:user)
             .where("users.id IS NULL OR users.id = ?", user.id)
             .order(:name)
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :developer_id, :password, :password_confirmation)
  end
end
