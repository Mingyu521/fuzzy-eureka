module ApplicationHelper
  CHANNEL_PALETTE = %w[#01fdf6 #ff10f0 #faed27 #bc13fe #0aff9d #ff9f1c].freeze

  def channel_color(name)
    CHANNEL_PALETTE[name.to_s.sum % CHANNEL_PALETTE.size]
  end

  # Supports **bold** and [text](url) only. Escapes everything else first.
  def simple_markdown(text)
    return "" if text.blank?

    escaped = ERB::Util.html_escape(text)
    escaped = escaped.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
    escaped = escaped.gsub(/\[(.+?)\]\((https?:\/\/[^\s)]+)\)/, '<a href="\2" target="_blank" rel="noopener">\1</a>')
    escaped.html_safe
  end

  def relative_time(time)
    diff = Time.current - time
    return "just now" if diff < 60
    return "#{(diff / 60).to_i} min ago" if diff < 3600
    return "#{(diff / 3600).to_i} hr ago" if diff < 86400
    return "yesterday at #{time.strftime('%-l:%M%P')}" if time.to_date == Date.yesterday
    return time.strftime("%b %-d at %-l:%M%P") if diff < 30.days
    time.strftime("%b %-d, %Y")
  end
end
