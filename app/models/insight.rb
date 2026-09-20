class Insight < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :value, presence: true
  validates :title, uniqueness: { scope: :project_id }

  after_create_commit :broadcast_created
  after_update_commit :broadcast_updated

  def self.upsert_value!(project:, title:, value:, icon: nil)
    insight = find_or_initialize_by(project: project, title: title)
    insight.value = value
    insight.icon = icon if icon.present?
    insight.save!
    insight
  end

  private

  def broadcast_created
    broadcast_append_to project, "insights", target: "insights-grid", partial: "insights/insight", locals: { insight: self }
  end

  def broadcast_updated
    broadcast_replace_to project, "insights", target: self, partial: "insights/insight", locals: { insight: self }
  end
end
