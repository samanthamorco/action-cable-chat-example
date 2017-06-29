class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    message = Message.new(content: params[:content], user: current_user, room_id: params[:room_id])
    if message.save
      ActionCable.server.broadcast 'messages',
        room_id: message.room_id,
        message: message.content,
        user: message.user.email
      head :ok
    end
  end
end
