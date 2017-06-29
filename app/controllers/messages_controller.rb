class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    @message = Message.new(content: params[:content], user: current_user, room_id: params[:room_id])
    if @message.save
      ActionCable.server.broadcast 'messages',
        message: message.content,
        user: message.user.email
      head :ok
    else
      flash[:warning] = "Message not added"
    end
      redirect_to room_path(params[:room_id])
  end
end
