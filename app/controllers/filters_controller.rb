class FiltersController < ApplicationController
  before_action :check_login
  before_action :set_filter, only: [:show, :edit, :update, :destroy]

  # CanCan checks
  authorize_resource

  # GET /filters
  def index
    @filters = Filter.alphabetical.page(params[:page])
  end

  # GET /filters/1
  def show
    @user_keys = @filter.user_keys
  end

  # GET /filters/new
  def new
    @filter = Filter.new
  end

  # GET /filters/1/edit
  def edit
  end

  # POST /filters
  def create
    @filter = Filter.new(filter_params)
    if @filter.save
      redirect_to @filter, notice: 'Filter was successfully created.'
    else
      render :new 
    end
  end

  # PATCH/PUT /filters/1
  def update
    if @filter.update(filter_params)
      redirect_to @filter, notice: 'Filter was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /filters/1
  def destroy
    @filter.destroy
    redirect_to filters_url, notice: 'Filter was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_filter
      @filter = Filter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def filter_params
      params.require(:filter).permit(:resource, :filter_name, :filter_value)
    end
end
