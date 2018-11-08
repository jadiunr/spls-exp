class StreamingSessionsController < ApplicationController
  before_action :set_streaming_session, only: [:show, :update, :destroy]

  # GET /streaming_sessions
  # GET /streaming_sessions.json
  def index
    @streaming_sessions = StreamingSession.all
  end

  # GET /streaming_sessions/1
  # GET /streaming_sessions/1.json
  def show
  end

  # POST /streaming_sessions
  # POST /streaming_sessions.json
  def create
    @streaming_session = StreamingSession.new(user_id: current_user.id)

    if @streaming_session.save
      render :show, status: :created, location: @streaming_session
    else
      render json: @streaming_session.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /streaming_sessions/1
  # PATCH/PUT /streaming_sessions/1.json
  def update
    if @streaming_session.update(streaming_session_params)
      render :show, status: :ok, location: @streaming_session
    else
      render json: @streaming_session.errors, status: :unprocessable_entity
    end
  end

  # DELETE /streaming_sessions/1
  # DELETE /streaming_sessions/1.json
  def destroy
    @streaming_session.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_streaming_session
      @streaming_session = StreamingSession.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def streaming_session_params
      params.require(:streaming_session).permit(:user_id)
    end
end
