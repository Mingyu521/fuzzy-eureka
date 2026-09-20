class Event < ApplicationRecord
  belongs_to :project

  validates :channel, presence: true
  validates :title, presence: true

  before_validation :ensure_channel_record

  after_create_commit :broadcast_created
  after_update_commit :broadcast_updated
  after_destroy_commit :broadcast_destroyed

  scope :recent_first, -> { order(created_at: :desc) }
  scope :in_channel, ->(channel) { channel.present? ? where(channel: channel) : all }
  scope :favorited_only, ->(flag) { flag ? where(favorited: true) : all }
  scope :search, lambda { |query|
    if query.present?
      where("title ILIKE :q OR description ILIKE :q OR tags::text ILIKE :q", q: "%#{query}%")
    else
      all
    end
  }

  def as_notification_json
    {
      id: id,
      channel: channel,
      title: title,
      description: description,
      icon: icon,
      tags: tags,
      url: url,
      user_id: user_id,
      notify: notify,
      favorited: favorited,
      created_at: created_at.iso8601
    }
  end

  private

  def ensure_channel_record
    return if project.nil? || channel.blank?

    Channel.find_or_create_by!(project: project, name: channel)
  end

  def broadcast_created
    broadcast_prepend_to project, "events", target: "events-feed", partial: "events/event", locals: { event: self }
  end

  def broadcast_updated
    broadcast_replace_to project, "events", target: self, partial: "events/event", locals: { event: self }
  end

  def broadcast_destroyed
    broadcast_remove_to project, "events", target: self
  end
end
