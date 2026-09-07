# Reconstructs who held each project role over time by replaying the project's
# audit trail, then measures how long each developer spent on it.
#
# Projects that predate the audit log have no change records, so their current
# assignment is shown as running from the project start and flagged as inferred.
class ProjectTimeline
  SLOTS = {
    "main_developer_id" => "Main",
    "helper_developer_id" => "Helper",
    "call_developer_id" => "On call",
    "lead_developer_id" => "Lead"
  }.freeze

  Stint = Struct.new(:developer_id, :name, :role, :started_at, :ended_at,
                     :inferred_start, :ongoing, :offset_pct, :width_pct, keyword_init: true) do
    def seconds
      [(ended_at - started_at).to_i, 0].max
    end
  end

  Lane = Struct.new(:field, :label, :stints, keyword_init: true)
  Tick = Struct.new(:label, :position_pct, keyword_init: true)
  Total = Struct.new(:developer_id, :name, :seconds, :roles, :share_pct, keyword_init: true)

  def initialize(project)
    @project = project
  end

  def lanes
    @lanes ||= SLOTS.map do |field, label|
      Lane.new(field: field, label: label, stints: stints_for(field))
    end
  end

  def any_stints?
    lanes.any? { |lane| lane.stints.any? }
  end

  # Time on the project per developer, across every role they held
  def totals
    @totals ||= begin
      grouped = lanes.flat_map(&:stints).group_by(&:developer_id)
      longest = grouped.values.map { |stints| merged_seconds(stints) }.max.to_i

      grouped.map { |developer_id, stints|
        seconds = merged_seconds(stints)
        Total.new(
          developer_id: developer_id,
          name: stints.first.name,
          seconds: seconds,
          roles: stints.map(&:role).uniq,
          share_pct: longest.zero? ? 0 : ((seconds * 100.0) / longest).round
        )
      }.sort_by { |total| -total.seconds }
    end
  end

  def ticks
    @ticks ||= begin
      months = ((ends_at - starts_at) / 1.month.to_f).ceil
      step = months > 18 ? 3 : 1
      cursor = starts_at.to_date.beginning_of_month
      cursor = cursor.next_month if cursor < starts_at.to_date

      list = []
      while cursor.to_time <= ends_at
        list << Tick.new(label: cursor.strftime("%b %y"), position_pct: position_of(cursor.to_time))
        cursor = cursor.advance(months: step)
      end
      list
    end
  end

  def starts_at
    @starts_at ||= [project.start_date&.to_time, project.created_at, first_change_at].compact.min
  end

  def ends_at
    @ends_at ||= project.completed? ? (completed_at || project.updated_at) : Time.current
  end

  def span_seconds
    @span_seconds ||= [(ends_at - starts_at).to_i, 1].max
  end

  def audits
    @audits ||= Audit.for_record(project).order(:created_at).to_a
  end

  private

  attr_reader :project

  # Someone holding two roles at once spent that time on the project once,
  # so overlapping stints are merged before measuring.
  def merged_seconds(stints)
    merged = []

    stints.map { |stint| [stint.started_at, stint.ended_at] }.sort_by(&:first).each do |start, finish|
      if merged.any? && start <= merged.last.last
        merged.last[1] = [merged.last.last, finish].max
      else
        merged << [start, finish]
      end
    end

    merged.sum { |start, finish| [(finish - start).to_i, 0].max }
  end

  def stints_for(field)
    events = change_events(field)
    return inferred_stints(field) if events.empty?

    stints = []

    # Whoever held the slot before the first recorded change
    opener = events.first[:from]
    if opener && events.first[:at] > starts_at
      stints << build_stint(opener, field, starts_at, events.first[:at], inferred_start: true)
    end

    events.each_with_index do |event, index|
      next if event[:to].blank?

      finish = events[index + 1]&.fetch(:at) || ends_at
      # Someone assigned when the project was created counts from the project
      # start date, which may be backdated well before the record existed.
      backdated = event[:created] && starts_at < event[:at]
      origin = backdated ? starts_at : event[:at]

      stints << build_stint(event[:to], field, origin, finish,
                            inferred_start: backdated, ongoing: events[index + 1].nil?)
    end

    stints
  end

  def inferred_stints(field)
    current = project.public_send(field)
    return [] if current.blank?

    [build_stint(current, field, starts_at, ends_at, inferred_start: true, ongoing: !project.completed?)]
  end

  def change_events(field)
    audits.filter_map do |audit|
      pair = audit.audited_changes[field]
      next unless pair.is_a?(Array)

      { at: audit.created_at, from: pair.first, to: pair.last, created: audit.action == "create" }
    end
  end

  def build_stint(developer_id, field, started_at, ended_at, inferred_start: false, ongoing: false)
    started_at = [started_at, starts_at].max
    ended_at = [ended_at, ends_at].min

    Stint.new(
      developer_id: developer_id,
      name: developer_names[developer_id] || "Developer ##{developer_id}",
      role: SLOTS.fetch(field),
      started_at: started_at,
      ended_at: ended_at,
      inferred_start: inferred_start,
      ongoing: ongoing,
      offset_pct: position_of(started_at),
      width_pct: [((ended_at - started_at) * 100.0 / span_seconds).round(2), 0.4].max
    )
  end

  def position_of(time)
    [(((time - starts_at) * 100.0) / span_seconds).round(2), 0].max
  end

  def first_change_at
    audits.first&.created_at
  end

  def completed_at
    audits.reverse.find { |audit| audit.audited_changes["status"]&.last == "completed" }&.created_at
  end

  def developer_names
    @developer_names ||= Developer.where(id: referenced_developer_ids).pluck(:id, :name).to_h
  end

  def referenced_developer_ids
    ids = SLOTS.keys.map { |field| project.public_send(field) }
    ids += audits.flat_map { |audit|
      SLOTS.keys.filter_map { |field| audit.audited_changes[field] }.flatten
    }
    ids.compact.uniq
  end
end
