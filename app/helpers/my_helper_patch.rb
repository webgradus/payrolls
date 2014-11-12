module MyHelperPatch
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def entries_total_cost(entries)
      entries_total_cost_array = []
      grouped_entries = entries.group_by(&:issue)
      grouped_entries.each do |issue, entries|
        rate = issue.rate
        all_issue_entries = TimeEntry.on_issue(issue).spent_between(Date.today - 6, Date.today).where("time_entries.created_on < ?", entries.first.created_on)
        estimated_hours = (issue.estimated_hours || 0) - (all_issue_entries - entries).sum(&:hours)
        user_issue_hours = entries.sum(&:hours)
        #if user_issue_hours <= estimated_hours # && issue.closed? && issue.paid_by_client?
          issue_state = if user_issue_hours > estimated_hours
                          :overdue
                        elsif !issue.closed?
                          :not_closed
                        elsif !issue.paid_by_client?
                          :not_paid
                        else
                          :done
                        end
          issue_total = user_issue_hours.to_f * rate
          issue_60_percent_part = issue_total * 0.6
          #issue_30_percent_part = [:overdue, :not_closed, :not_paid].include?(issue_state) ? 0 : issue_total * 0.3
          issue_30_percent_part = issue_total * 0.3
          issue_10_percent_part = issue.project.quality? ? issue_total * 0.1 : 0
          entries_total_cost_array << {0.6 => issue_60_percent_part, 0.3 => issue_30_percent_part, 0.1 => issue_10_percent_part, :state => issue_state}
        #else
          #entries_total_cost += estimated_hours.to_f * rate
          #entries_total_cost += (estimated_hours - user_issue_hours).to_f * (rate / 2)
        #end
      end
      entries_total_cost_array
    end

    def month_timelog_items
      TimeEntry.
        where("#{TimeEntry.table_name}.user_id = ? AND #{TimeEntry.table_name}.spent_on BETWEEN ? AND ?", User.current.id, Date.today.at_beginning_of_month, Date.today).
        includes(:activity, :project, {:issue => [:tracker, :status]}).
        order("#{TimeEntry.table_name}.spent_on DESC, #{Project.table_name}.name ASC, #{Tracker.table_name}.position ASC, #{Issue.table_name}.id ASC").
        all
    end
  end
end
