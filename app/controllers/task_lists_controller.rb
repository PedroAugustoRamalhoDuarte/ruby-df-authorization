class TaskListsController < ApplicationController
  before_action :set_task_list, only: [:show]
  before_action -> { authorize! @task_list, with: TaskListPolicy }

  def index
    # Without action_policy
    # @task_lists = current_user.admin? ? Task.all :
    #                 TaskList.left_outer_joins(:user_task_lists)
    #                         .where('task_lists.user_id = ? OR user_task_lists.user_id = ?', user.id, user.id)
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
    # if !current_user.admin? and @task_list.user_id != current_user.id and !@task_list.users.includes?(current_user)
    #   unauthorized
    # end
    @tasks = @task_list.tasks
  end

  def create
    # Without action policy
    # if !current_user.admin? and current_user.task_lists.count >= current_user.plan.task_list_limit
    #   unauthorized(message: "Você chegou no limite de lista de tarefas do seu plano")
    # end
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
