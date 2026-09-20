module Api
  class ChartsController < BaseController
    def show
      project = Project.find(params.require(:project))
      since = 30.days.ago.beginning_of_day

      daily = project.events.where("created_at >= ?", since)
                     .group("DATE(created_at)")
                     .order("DATE(created_at)")
                     .count

      by_channel = project.events.group(:channel).count

      by_channel_daily = project.events.where("created_at >= ?", since)
                                .group(:channel, "DATE(created_at)")
                                .order("DATE(created_at)")
                                .count
                                .each_with_object({}) do |((channel, date), count), acc|
                                  (acc[channel] ||= []) << { date: date.to_s, count: count }
                                end

      render json: {
        daily: daily.map { |date, count| { date: date.to_s, count: count } },
        by_channel: by_channel.map { |channel, count| { channel: channel, count: count } },
        by_channel_daily: by_channel_daily
      }
    end
  end
end
