class RoomsController < ApplicationController
  before_action :authenticate_user!
  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
  end

  def new
  end

  def create
    room = Room.create(title: params[:title])
    redirect_to room_path(room)
  end
end
