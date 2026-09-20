module Api
  class InsightsController < BaseController
    before_action :authenticate_project!

    def create
      insight = Insight.upsert_value!(
        project: current_project,
        title: params.require(:title),
        value: params.require(:value).to_s,
        icon: params[:icon]
      )

      render json: {
        id: insight.id,
        title: insight.title,
        value: insight.value,
        icon: insight.icon,
        updated_at: insight.updated_at.iso8601
      }
    end
  end
end
