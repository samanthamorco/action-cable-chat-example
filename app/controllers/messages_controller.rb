class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    @message = Message.create(content: params[:content], user: current_user, room_id: params[:room_id])
    redirect_to room_path(params[:room_id])
  end
end
