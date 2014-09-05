module ProjectPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def quality?
      custom_value = CustomValue.joins(:custom_field).where("custom_fields.name = ? and customized_type=? and customized_id = ?", I18n.t(:passed_quality_check, locale: :ru), self.class.name, self.id).first
      custom_value.try(:true?)
    end

  end
end
