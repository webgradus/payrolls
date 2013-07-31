Rails.configuration.to_prepare do
  require File.expand_path(File.join(File.dirname(__FILE__), "app/helpers/my_helper_patch"))
  MyHelper.send     :include, MyHelperPatch
  UserPreference.send :include, UserPreferencePatch
end

Redmine::Plugin.register :payrolls do
  name 'Payrolls plugin'
  author 'Gradus'
  description 'Payrolls plugin for Redmine'
  version '0.0.1'
  url 'http://github.com/webgradus/payrolls'
  author_url 'http://webgradus.ru'

  settings :default => {'empty' => true}, :partial => 'settings/payrolls_settings'
end
