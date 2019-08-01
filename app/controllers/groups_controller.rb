class GroupsController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :join, :quit]
  before_action :find_group_and_check_permission, only: [:edit, :update, :destroy]
  def index
    @groups = Group.all
  end

  def show
    @group = Group.find(params[:id])
    @posts = @group.posts.recent.paginate(:page => params[:page], :per_page => 5)
  end

  def edit
  end

  def new
   @group = Group.new
  end

  def create
   @group = Group.new(group_params)
   @group.user = current_user
   if @group.save
     current_user.join!(@group)
     redirect_to groups_path
   else
     render :new
   end
 end

 def update
   if @group.update(group_params)
   redirect_to groups_path, notice: "更新成功!"
 else
   render :edit
   end
 end

 def destroy
   @group.destroy
   redirect_to groups_path, alert: "电影已删除!"
 end

   def join
   @group = Group.find(params[:id])

    if !current_user.is_member_of?(@group)
      current_user.join!(@group)
      flash[:notice] = "收藏本电影成功！"
    else
      flash[:warning] = "你已经收藏过本电影了！"
    end

    redirect_to group_path(@group)
  end

  def quit
    @group = Group.find(params[:id])

    if current_user.is_member_of?(@group)
      current_user.quit!(@group)
      flash[:alert] = "已取消收藏！"
    else
      flash[:warning] = "你还没收藏，怎么取消"
    end

    redirect_to group_path(@group)
  end

private

  def find_group_and_check_permission
    @group = Group.find(params[:id])
    if current_user != @group.user
      redirect_to root_path, alert: "你没有许可，请先登陆!"
    end
  end

  def group_params
    params.require(:group).permit(:title, :description)
 end
end
