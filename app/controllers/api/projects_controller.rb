module Api
  class ProjectsController < BaseController
    def create
      project = Project.create!(name: params.require(:name))
      render json: {
        id: project.id,
        name: project.name,
        api_key: project.api_key,
        created_at: project.created_at.iso8601
      }, status: :created
    end
  end
end
