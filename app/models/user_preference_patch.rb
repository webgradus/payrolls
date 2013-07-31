module UserPreferencePatch
  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def my_page_layout
      self[:my_page_layout]
    end

    def my_page_layout=(value)
      self[:my_page_layout]=((value.present? && value) ||  {'top' => ['issuesassignedtome', 'timelog', 'monthtotals']})
    end
  end
end
