module MyHelperPatch
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def entries_total_cost(entries)
      entries_total_cost = 0
      grouped_entries = entries.group_by(&:issue)
      grouped_entries.each do |issue, entries|
        all_issue_entries = TimeEntry.on_issue(issue).spent_between(Date.today - 6, Date.today)
        estimated_hours = issue.estimated_hours - (all_issue_entries - entries).sum(&:hours)
        user_issue_hours = entries.sum(&:hours)
        if user_issue_hours <= estimated_hours
          entries_total_cost += user_issue_hours.to_f * Setting.plugin_payrolls['developer_rate'].to_f
        else
          entries_total_cost += estimated_hours.to_f * Setting.plugin_payrolls['developer_rate'].to_f
          entries_total_cost += (estimated_hours - user_issue_hours).to_f * (Setting.plugin_payrolls['developer_rate'].to_f / 2)
        end
      end
      entries_total_cost
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
