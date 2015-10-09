module MyHelperPatch
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    def select_entries(entries, criterias, level, hours_for_value)
        scope = entries
        (0..level).each do |l|
            scope = scope.where("time_entries.#{criterias[l]}_id in (?)", hours_for_value.map {|h| h[criterias[l]] })
        end
        scope
    end

    def entries_total_cost(entries)
      entries_total_cost = 0
      grouped_entries = entries.group_by(&:issue)
      grouped_entries.each do |issue, entries|
        user_issue_hours = entries.sum(&:hours)
        rate = issue.assigned_to ? Rate.amount_for(issue.assigned_to, issue.project) : 0
        if user_issue_hours > (issue.estimated_hours || 0)
          entries_total_cost += (issue.estimated_hours || 0).to_f * rate
        else
          entries_total_cost += entries.sum(&:cost)
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
