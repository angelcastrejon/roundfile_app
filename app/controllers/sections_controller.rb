class SectionsController < ApplicationController
  before_action :authenticate!, except: [:show]
  before_action :set_section, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def show
  end

  def new
    @section = current_user.sections.build
  end

  def create
    @section = current_user.sections.build(section_params)
    if @section.save
      redirect_to @section, notice: "Section created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @section.update(section_params)
      redirect_to @section, notice: "Section updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @section.destroy
    redirect_to my_sections_path, notice: "Section deleted."
  end

  def my_sections
    @sections = current_user.sections.order(:section_type, :title)
  end

  private

  def set_section
    @section = Section.find(params[:id])
  end

  def authorize_owner!
    redirect_to root_path, alert: "Not authorized." unless @section.user == current_user
  end

  def section_params
    params.expect(section: [:section_type, :title, :content])
  end
end
