class ResumesController < ApplicationController
  
  def show
	@resume = Resume.find(params[:id])
	
	@resumesection = Resumesection.find_all_by_resumeid(params[:id], :order => "orderNum")
	@comment = Comment.find_all_by_resumeid(params[:id], :order => "created_at")
	@rating = Rating.find_all_by_resumeid(params[:id], :order => "created_at")
	
	#@section = Section.find(:all)
	
	@title = "View Resume"
  end
  
  def new
    @title = "New Resume"
	@resume = Resume.new
  end
  
  def create	
    @resume = current_user.resumes.build(params[:resume])
    if @resume.save
      flash[:success] = "Resume created!"
      redirect_to "/newresume/#{@resume.id}"
	else
      @title = "Create Resume"
      render 'new'
    end
  end
  
  def allresumes
	@title = "All Resumes"
	@resume = Resume.all
	
	#code from DEMO APP
	respond_to do |format|
      format.html
      format.xml  { render :xml => @resume }
    end
  end
	
  def myresumes
	@title = "My Resumes"
	@resume = Resume.find_all_by_userid(current_user.id)
	
	
	#code from DEMO APP
	respond_to do |format|
      format.html 
      format.xml  { render :xml => @resume }
    end
  end
  
  def userres
	@title = "Find Resumes by User"
	@user = User.find(:all)
	@resume = Resume.find_all_by_userid(params[:id])
	if (!params[:id].blank?)
		@userselected = User.find(params[:id])
		@title2 = "#{@userselected.name}'s Resumes"
	else
		@title2 = " "
	end
	
  end

  
end
