require 'redmine'
ActionDispatch::Callbacks.to_prepare do
    # use require_dependency if you plan to utilize development mode
    require 'my_helper_patch'
end
Rails.configuration.to_prepare do
  # require File.expand_path(File.join(File.dirname(__FILE__), "app/helpers/my_helper_patch"))
  UserPreference.send :include, UserPreferencePatch
  Issue.send :include, IssuePatch
  Project.send :include, ProjectPatch
end

Redmine::Plugin.register :payrolls do
  name 'Payrolls plugin'
  author 'Gradus'
  description 'Payrolls plugin for Redmine'
  version '0.1.0'
  url 'http://github.com/webgradus/payrolls'
  author_url 'http://webgradus.ru'

  settings :default => {'empty' => true}, :partial => 'settings/payrolls_settings'
end
