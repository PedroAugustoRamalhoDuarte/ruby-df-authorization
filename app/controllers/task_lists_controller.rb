class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show]
  before_action -> { authorize! @task_list, with: TaskListPolicy }

  def index
    # Without action_policy
    # @task_lists = TaskList.joins(:user_task_lists)
    #                        .where(user_id: current_user.id)
    #                        .where(user_task_lists: { user_id: current_user.id })
    @task_lists = authorized_scope(TaskList.all)
  end

  def new
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("new_task_list", partial: "task_lists/form", locals: { task_list: TaskList.new })
      end
    end
  end

  def show
    # Without action_policy
    # if @task_list.user_task_list.user_id != current_user.id or @task_list.user_task_list.user_id != current_user.id
    #  unauthorized
    # end
    @tasks = @task_list.tasks
  end

  def create
    unless current_user.task_lists.count < current_user.plan.task_list_limit
      unauthorized(message: "Você chegou no limite de lista de tarefas do seu plano")
    end
    @task_list = TaskList.create!(task_list_params)
  rescue StandardError => e
    flash[:error] = e.full_message
    redirect_to task_lists_path
  end

  private

  def unauthorized(message: "Você não tem permissão para acessar este recurso")
    flash[:error] = message
    redirect_to root_path
  end

  def task_list_params
    params.require(:task_list).permit(:name)
  end

  def set_task_list
    @task_list = TaskList.find(params[:id])
  end
end
