#!/bin/env ruby
# encoding: utf-8

require 'redmine'
require 'dispatcher' unless Rails::VERSION::MAJOR >= 3
require File.expand_path 'lib/mailer_patch', __dir__

Redmine::Plugin.register :redmine_email_notification_content_filter do
  name 'Redmine Email Notification Content Filter plugin'
  author 'Sébastien Leroux, Lari Taskula'
  description 'This is a plugin for Redmine that allows to remove the description in the notification emails. Forked from https://github.com/keeps/redmine_email_notification_content_filter'
  version '5.0.5.1'
  url 'https://github.com/Hypernova-Oy/redmine_email_notification_content_filter'
  settings(:default => {
    'removeDescriptionFromDocument' => 'false',
    'removeDescriptionFromNews' => 'false',
    'removeDescriptionFromIssue' => 'false'
  }, :partial => 'settings/redmine_email_notification_content_filter')
  project_module :email_notification_content_filter do
    permission :block_email, {:email_notification_content_filter => :show}
  end
end

Mailer.prepend(MailerPatch)
