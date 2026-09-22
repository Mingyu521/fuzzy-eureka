module Api
  class EventsController < BaseController
    before_action :authenticate_project!, only: [ :create, :favorite, :delete ]

    MAX_LIMIT = 200

    def index
      project = Project.find(params.require(:project))

      events = project.events.recent_first
                       .in_channel(params[:channel])
                       .favorited_only(ActiveModel::Type::Boolean.new.cast(params[:favorites]))
                       .search(params[:search])

      cursor = params[:cursor].presence&.to_i
      events = events.where("events.id < ?", cursor) if cursor

      limit = [ params[:limit].presence&.to_i || 50, MAX_LIMIT ].min
      page = events.limit(limit + 1).to_a
      has_more = page.size > limit
      page = page.first(limit)

      render json: {
        events: page.map { |e| serialize(e) },
        nextCursor: has_more ? page.last&.id : nil
      }
    end

    def create
      event = current_project.events.build(event_params)
      event.save!
      render json: serialize(event), status: :created
    end

    def favorite
      event = current_project.events.find(params[:id])
      event.update!(favorited: !event.favorited)
      render json: { favorited: event.favorited }
    end

    def delete
      event = current_project.events.find(params[:id])
      event.destroy!
      render json: { ok: true }
    end

    private

    def event_params
      permitted = params.permit(:channel, :title, :description, :icon, :url, :user_id, :notify)
      permitted[:tags] = params[:tags].is_a?(ActionController::Parameters) ? params[:tags].to_unsafe_h : (params[:tags] || {})
      permitted
    end

    def serialize(event)
      {
        id: event.id,
        channel: event.channel,
        title: event.title,
        description: event.description,
        icon: event.icon,
        tags: event.tags,
        url: event.url,
        user_id: event.user_id,
        notify: event.notify,
        favorited: event.favorited,
        created_at: event.created_at.iso8601
      }
    end
  end
end
