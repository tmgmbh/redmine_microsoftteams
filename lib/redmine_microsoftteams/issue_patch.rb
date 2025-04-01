module RedmineMicrosoftteams
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        after_save :save_from_issue
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def save_from_issue
	if self.current_journal.nil?
	  return true
	end
        status_changed = false
	self.current_journal.details.each do |detail|
	  if detail.prop_key === 'status_id' && detail.old_value.to_i != self.status_id.to_i
	    status_changed = true
          end
	end
	if self.status_id.to_i === Setting.plugin_redmine_microsoftteams['status_id'].to_i && status_changed
          Redmine::Hook.call_hook(:redmine_microsoftteams_issues_edit_after_save, { :issue => self, :journal => self.current_journal})
        end
        return true
      end
    end
  end
end
