module ApplicationHelper
  BADGE_COLORS = {
    "active" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "hold" => "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    "completed" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "won" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "lost" => "bg-red-50 text-red-700 ring-1 ring-red-200",
    "available" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "unavailable" => "bg-ink-100 text-ink-600 ring-1 ring-ink-200",
    "not_available" => "bg-ink-100 text-ink-600 ring-1 ring-ink-200",
    "ror" => "bg-rose-50 text-rose-800 ring-1 ring-rose-200",
    "mern" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "other" => "bg-ink-100 text-ink-700 ring-1 ring-ink-200",
    "pending" => "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    "draft" => "bg-ink-100 text-ink-600 ring-1 ring-ink-200",
    "cleared" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "monthly" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "fixed_price" => "bg-violet-50 text-violet-800 ring-1 ring-violet-200",
    "todo" => "bg-ink-100 text-ink-700 ring-1 ring-ink-200",
    "in_progress" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "done" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "low" => "bg-ink-100 text-ink-600 ring-1 ring-ink-200",
    "medium" => "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    "high" => "bg-red-50 text-red-700 ring-1 ring-red-200",
    "junior" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "mid" => "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    "senior" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "lead" => "bg-violet-50 text-violet-800 ring-1 ring-violet-200",
    "scheduled" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "cancelled" => "bg-ink-100 text-ink-600 ring-1 ring-ink-200",
    "paused" => "bg-amber-50 text-amber-800 ring-1 ring-amber-200",
    "main" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "admin" => "bg-violet-50 text-violet-800 ring-1 ring-violet-200",
    "manager" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "team_lead" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "developer" => "bg-ink-100 text-ink-700 ring-1 ring-ink-200",
    "create" => "bg-accent-100 text-accent-800 ring-1 ring-accent-200",
    "update" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "destroy" => "bg-red-50 text-red-700 ring-1 ring-red-200",
    "helper" => "bg-sky-50 text-sky-800 ring-1 ring-sky-200",
    "call" => "bg-violet-50 text-violet-800 ring-1 ring-violet-200",
    "support" => "bg-ink-100 text-ink-700 ring-1 ring-ink-200",
  }.freeze

  PROFICIENCY_COLORS = {
    "na" => "#f2f2f2",
    "beginner" => "#ffc7ce",
    "intermediate" => "#ffeb9c",
    "advanced" => "#ddebf7",
    "expert" => "#c6efce",
  }.freeze

  def status_badge(status)
    classes = BADGE_COLORS.fetch(status.to_s, "bg-ink-100 text-ink-600 ring-1 ring-ink-200")
    content_tag(:span, status.to_s.humanize, class: "badge #{classes}")
  end

  def proficiency_badge(level)
    hex = proficiency_bg(level)
    label = level.to_s == "na" ? "NA" : level.to_s.humanize
    content_tag(:span, label, class: "badge text-ink-800", style: "background-color: #{hex}")
  end

  def proficiency_bg(level)
    PROFICIENCY_COLORS.fetch(level.to_s, "#f2f2f2")
  end

  # Single source of truth for the projects table: header cells, the column
  # toggle menu, and the data-column keys used on each <td> in projects/_row.
  def project_table_columns
    columns = [
      { key: "name", label: "Project", locked: true },
      { key: "technology", label: "Technology" },
      { key: "start", label: "Start" },
      { key: "billing", label: "Billing" },
      { key: "status", label: "Status" },
      { key: "call", label: "Call" },
      { key: "lead", label: "Lead" },
      { key: "main", label: "Main Developer" }
    ]
    columns << { key: "incentive", label: "Incentive" } if can?(:view_incentives)
    columns << { key: "pending", label: "Pending" }
    columns << { key: "actions", label: "Actions", header: "" }
    columns
  end

  # "Yashika Vijayvargiya" -> "Yashika V."
  def short_name(name)
    cleaned = name.to_s.gsub(/\(.*?\)/, "").strip
    return "" if cleaned.blank?

    first, *rest = cleaned.split(/\s+/)
    return first if rest.empty?

    "#{first} #{rest.last[0].upcase}."
  end

  # Cached per request so the projects table doesn't rebuild the list per row
  def developer_cell_options(short: false)
    @developer_cell_options ||= Developer.order(:name).pluck(:name, :id)
    return @developer_cell_options unless short

    @developer_short_cell_options ||= @developer_cell_options.map { |name, id| [short_name(name), id] }
  end

  def money(amount)
    return "—" if amount.blank?

    number_to_currency(amount, unit: "₹", precision: 0)
  end

  def hours_label(hours)
    return "—" if hours.blank?

    "#{number_with_precision(hours, precision: 1, strip_insignificant_zeros: true)}h"
  end

  def rating_stars(rating)
    return content_tag(:span, "—", class: "text-ink-400 text-sm") if rating.blank?

    safe_join([
      content_tag(:span, "★" * rating.to_i, class: "text-amber-500"),
      content_tag(:span, "☆" * (5 - rating.to_i), class: "text-ink-300"),
      content_tag(:span, " #{rating}", class: "text-xs text-ink-500 align-middle")
    ])
  end

  def initials_avatar(name, size: "h-8 w-8")
    initials = name.to_s.gsub(/\(.*?\)/, "").strip.split(" ").map { |p| p[0] }.first(2).join.upcase
    content_tag(:span, initials, class: "flex #{size} shrink-0 items-center justify-center rounded-full text-xs font-semibold text-white #{avatar_color(name)}")
  end

  # Same colour a person gets in their avatar, so timeline bars stay recognisable
  def avatar_color(name)
    AVATAR_COLORS[name.to_s.sum % AVATAR_COLORS.length]
  end

  def duration_label(seconds)
    seconds = seconds.to_i
    return "—" if seconds <= 0

    days = seconds / 86_400
    return "#{(seconds / 3600.0).round}h" if days < 1
    return "#{days}d" if days < 45

    months, remainder = days.divmod(30)
    remainder.zero? ? "#{months}mo" : "#{months}mo #{remainder}d"
  end

  def nav_icon(name)
    paths = {
      "grid" => '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
      "people" => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
      "folder" => '<path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>',
      "matrix" => '<path d="M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z"/>',
      "leads" => '<path d="M8 6h13"/><path d="M8 12h13"/><path d="M8 18h13"/><path d="M3 6h.01"/><path d="M3 12h.01"/><path d="M3 18h.01"/>',
      "accounts" => '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/><path d="M16 11h6"/><path d="M19 8v6"/>',
      "billing" => '<rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M6 15h4"/>',
      "feedback" => '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>',
      "assessment" => '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M16 13H8"/><path d="M16 17H8"/><path d="M10 9H8"/>',
      "todos" => '<path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>',
      "oneonone" => '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
      "bench" => '<path d="M4 19h16"/><path d="M4 15h16"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/><path d="M6 15V11h12v4"/>',
      "util" => '<path d="M3 3v18h18"/><path d="M7 14l4-4 4 4 5-6"/>',
      "audit" => '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
      "hierarchy" => '<rect x="9" y="3" width="6" height="5" rx="1.5"/><rect x="2" y="16" width="6" height="5" rx="1.5"/><rect x="16" y="16" width="6" height="5" rx="1.5"/><path d="M12 8v4"/><path d="M5 16v-4h14v4"/>',
    }
    content_tag(:svg, paths.fetch(name, "").html_safe,
      width: 16, height: 16, viewBox: "0 0 24 24", fill: "none",
      stroke: "currentColor", "stroke-width": 1.8, "stroke-linecap": "round", "stroke-linejoin": "round",
      class: "opacity-80")
  end

  AVATAR_COLORS = %w[
    bg-accent-600 bg-ink-700 bg-rose-500 bg-sky-600 bg-amber-600 bg-teal-600 bg-fuchsia-600 bg-lime-700
  ].freeze
end
