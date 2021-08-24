class CustomerManagementsController < ApplicationController
  before_action :authenticate_employee! , except: %i[top]
  before_action :set_project, only: %i[edit update show]

  def new
    @project = Project.new
    @department = Department.where(web_flg: true)
    @employee = Employee.where(web_flg: true).order(department_id: :ASC).all
    @customeruser = Customeruser.all
    @customer = Customer.all
    @package = Package.all
    @feature = Feature.all
  end
  
  def set_employee
    # employeesをdepartment_idで絞り込んで取得する。
    @employee = Employee.where(department_id: params[:department][:department_id])
  end

  def index
    @department = Department.where(web_flg: true)
    @customer = Customer.all
    # @projects = Project.left_joins(:employee ,:customeruser ,:feature).select("titles.*, employee_ids.*, customeruser_ids.*, feature_ids.*, descriptions.*, prioritys.*, deadlines.*, department_ids.*, customer_ids.*")
    @projects = Project.all
    @q = @projects.ransack(params[:q])


    if params[:sort_checked].present?

          @check = Check.where(employee_id: current_employee.id)

          if @check.count > 0

            #親データから子データを絞り込み
            @customer = []
            @check.all.each do |ck|
              @customer << ck.customer_id
            end
            @cuser = Customeruser.where(customer_id: @customer)

            #絞り込んだデータから作成物のIDを取り出す
            @customeruser=[]
            @cuser.all.each do |cid|
              @customeruser << cid.id
            end

            @projects = Project.where(customeruser_id: @customeruser)
            @projects = @projects.order(apoint_at: :ASC).page(params[:page]).per(5)

          else

              flash[:notice] = "状況管理しているものはありません。"
              @projects = @q.result.order("apoint_at asc").page(params[:page]).per(5)
          end

    elsif params[:search].present?

          if params[:search][:department_id].present?

            #親データから子データを絞り込み
            @employee = Employee.where(department_id: params[:search][:department_id])

            #絞り込んだデータから作成物を取り出す
            @emp_id=[]
            @employee.all.each do |emp|
              @emp_id << emp.id
            end

            @projects = Project.where(employee_id: @emp_id)

          end

          if params[:search][:customer_id].present?

            #親データから子データを絞り込み
            @cuser = Customeruser.where(customer_id: params[:search][:customer_id])

            #絞り込んだデータから作成物を取り出す
            #絞り込んだデータから作成物のIDを取り出す
            @cuser_id=[]
            @cuser.all.each do |cuser|
              @cuser_id << cuser.id
            end

            @projects = Project.where(customeruser_id: @cuser_id)


          end

          @projects = @projects.order(apoint_at: :ASC).page(params[:page]).per(5)

    else

      # binding.pry
      @projects = @q.result.order("apoint_at asc").page(params[:page]).per(5)
    end

  end

  def show
  end
  def top
  end

  def edit
    @projects = Project.find(params[:id])
    @department = Department.where(web_flg: true)
    @customer = Customer.all
    @package = Package.all
  end


  def update
    #binding.pry
    if @project.update(project_params)
      redirect_to customer_managements_path  flash[:notice] = "レポートが編集されました。"
    else
      redirect_to customer_managements_path  flash[:notice] = "レポートの編集が失敗しました。"
    end
  end


  def create

    @project =Project.new(project_params)
      if @project.save
        redirect_to new_customer_management_path  flash[:notice] = "レポートが作成されました。"
      else
        redirect_to new_customer_management_path  flash[:notice] = "レポートの作成が失敗しました。"
      end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end


  def project_params
    params.require(:project).permit(:title, :employee_id, :customeruser_id, :feature_id, :description, :apoint_at, :priority, :deadline  )
  end

end