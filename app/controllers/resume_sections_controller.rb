class ResumeSectionsController < ApplicationController
  before_action :authenticate!
  before_action :set_resume

  def create
    next_position = (@resume.resume_sections.maximum(:position) || 0) + 1
    @resume_section = @resume.resume_sections.build(resume_section_params.merge(position: next_position))

    if @resume_section.save
      redirect_to edit_resume_path(@resume), notice: "Section added to resume."
    else
      redirect_to edit_resume_path(@resume), alert: "Could not add section. Make sure it's not already in the resume."
    end
  end

  def update
    @resume_section = @resume.resume_sections.find(params[:id])
    if @resume_section.update(resume_section_params)
      redirect_to edit_resume_path(@resume), notice: "Section order updated."
    else
      redirect_to edit_resume_path(@resume), alert: "Could not update section order."
    end
  end

  def destroy
    @resume_section = @resume.resume_sections.find(params[:id])
    @resume_section.destroy
    redirect_to edit_resume_path(@resume), notice: "Section removed from resume."
  end

  private

  def set_resume
    @resume = current_user.resumes.find(params[:resume_id])
  end

  def resume_section_params
    params.expect(resume_section: [:section_id, :position])
  end
end
