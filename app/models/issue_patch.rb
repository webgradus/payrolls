module IssuePatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def paid_by_client?
      custom_value = CustomValue.joins(:custom_field).where("custom_fields.name = ? and customized_type=? and customized_id = ?", I18n.t(:paid_by_client, locale: :ru), self.class.name, self.id).first
      custom_value.try(:true?)
    end

    def rate
      if self.assigned_to && self.assigned_to.roles_for_project(self.project).map(&:name).include?(I18n.t("trainee"))
        Setting.plugin_payrolls['trainee_rate'].to_f
      else
        Setting.plugin_payrolls['developer_rate'].to_f
      end
    end
  end
end
