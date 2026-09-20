class ProjectsController < ApplicationController
  before_action :set_project, only: [ :destroy, :feed, :charts, :insight, :playground, :settings ]

  PER_PAGE_OPTIONS = %w[50 100 all].freeze

  def index
    @projects = Project.order(created_at: :desc)
  end

  def create
    @project = Project.create!(name: params.require(:name))
    redirect_to feed_project_path(@project), notice: "Project \"#{@project.name}\" created."
  end

  def destroy
    @project.destroy!
    redirect_to root_path, notice: "Project deleted."
  end

  def feed
    scope = @project.events.recent_first
                     .in_channel(params[:channel])
                     .favorited_only(params[:favorites] == "1")
                     .search(params[:search])

    @per_page = PER_PAGE_OPTIONS.include?(params[:per_page]) ? params[:per_page] : "50"
    @page = [ params[:page].to_i, 1 ].max

    if @per_page == "all"
      @events = scope.to_a
      @total_pages = 1
    else
      limit = @per_page.to_i
      total = scope.count
      @total_pages = [ (total.to_f / limit).ceil, 1 ].max
      @page = [ @page, @total_pages ].min
      @events = scope.offset((@page - 1) * limit).limit(limit)
    end

    @channel_counts = @project.events.group(:channel).count.sort.to_h
    @selected_channel = params[:channel]
    @favorites_only = params[:favorites] == "1"
    @search = params[:search]
  end

  def charts
  end

  def insight
    @insights = @project.insights.order(:title)
  end

  def playground
  end

  def settings
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end
end
