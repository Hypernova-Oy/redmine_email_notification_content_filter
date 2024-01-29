module MailerPatch
  def issue_add(user, issue)

    show_journal_details = true
    show_journal_author = true

    redmine_headers 'Issue-Tracker' => issue.tracker.name,
                    'Issue-Id' => issue.id
    if issue.project.module_enabled?('email_notification_content_filter')
      if Setting.plugin_redmine_email_notification_content_filter['removeDescription']
        issue.description = ''
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeSubject']
        issue.subject = l(:issue_created)
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeVisibleDetails']
        show_journal_details = false
      else
        redmine_headers 'Project' => issue.project.identifier
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeAuthor']
        show_journal_author = false
      else
        redmine_headers 'Issue-Author' => issue.author.login,
                        'Issue-Assignee' => assignee_for_header(issue)
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeStatus']
        issue.status.name = ''
      end
    end

    message_id issue
    references issue
    @author = issue.author
    @email_notification_content_filter_enabled = issue.project.module_enabled?('email_notification_content_filter')
    @issue = issue
    @user = user
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
    @show_journal_author = show_journal_author
    @show_journal_details = show_journal_details
    if Setting.plugin_redmine_email_notification_content_filter['removeSubject']
      subject = "[#{issue.tracker.name} ##{issue.id}] "
    else
      subject = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    end
    if !Setting.plugin_redmine_email_notification_content_filter['removeStatus']
      subject += "(#{issue.status.name}) " if Setting.show_status_changes_in_mail_subject?
    end
    subject += " #{issue.subject}"
    mail :to => user,
      :subject => subject

  end

  def issue_edit(user, journal)
    issue = journal.journalized

    show_journal_details = true
    show_journal_author = true

    redmine_headers 'Issue-Tracker' => issue.tracker.name,
                    'Issue-Id' => issue.id
    if issue.project.module_enabled?('email_notification_content_filter')
      if Setting.plugin_redmine_email_notification_content_filter['removeDescription']
        issue.description = ''
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeSubject']
        issue.subject = l(:issue_updated)
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeNote']
        journal.notes = ''
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeVisibleDetails']
        show_journal_details = false
      else
        redmine_headers 'Project' => issue.project.identifier
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeAuthor']
        show_journal_author = false
      else
        redmine_headers 'Issue-Author' => issue.author.login,
                        'Issue-Assignee' => assignee_for_header(issue)
      end
      if Setting.plugin_redmine_email_notification_content_filter['removeStatus']
        issue.status.name = ''
      end
    end

    message_id journal
    references issue
    @author = journal.user
    if Setting.plugin_redmine_email_notification_content_filter['removeSubject']
      s = "[#{issue.tracker.name} ##{issue.id}] "
    else
      s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    end
    if !Setting.plugin_redmine_email_notification_content_filter['removeStatus']
      s += "(#{issue.status.name}) " if journal.new_value_for('status_id') && Setting.show_status_changes_in_mail_subject?
    end
    s += issue.subject
    @email_notification_content_filter_enabled = issue.project.module_enabled?('email_notification_content_filter')
    @issue = issue
    @user = user
    @journal = journal
    @journal_details = journal.visible_details
    @show_journal_author = show_journal_author
    @show_journal_details = show_journal_details
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")

    mail :to => user,
      :subject => s

  end
end
