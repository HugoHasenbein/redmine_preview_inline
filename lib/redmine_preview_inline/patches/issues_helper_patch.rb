# encoding: utf-8
#
# Redmine plugin to preview an attachment inline
#
# Copyright © 2018 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

module RedminePreviewInline
  module Patches 
    module IssuesHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do

          unloadable 
          
          alias_method_chain :show_detail, :view_inline
          
        end #base
      end #self

      module InstanceMethods
      
		# Returns the textual representation of a single journal detail
		# unluckily, for a small change only I need to copy and patch the whole function
		# because the attachment detail is deeply nested within original show_detail
		
		def show_detail_with_view_inline(detail, no_html=false, options={})
		  multiple = false
		  show_diff = false
		  no_details = false

		  case detail.property
		  when 'attachment'
			label = l(:label_attachment)
			value = nil
			old_value = nil
		  end
		  call_hook(:helper_issues_show_detail_after_setting,
					{:detail => detail, :label => label, :value => value, :old_value => old_value })

		  label ||= detail.prop_key
		  value ||= detail.value
		  old_value ||= detail.old_value

		  unless no_html
			label = content_tag('strong', label)
			old_value = content_tag("i", h(old_value)) if detail.old_value
			if detail.old_value && detail.value.blank? && detail.property != 'relation'
			  old_value = content_tag("del", old_value)
			end
			if detail.property == 'attachment' && value.present? &&
				atta = detail.journal.journalized.attachments.detect {|a| a.id == detail.prop_key.to_i}
			  # Link to the attachment if it has not been removed
			  value = link_to_attachment(atta, only_path: options[:only_path])
			  if options[:only_path] != false
			    preview_div_id = SecureRandom.uuid.to_s.gsub(/\-/, "_")
			    preview_tag_id = SecureRandom.uuid.to_s.gsub(/\-/, "_")
				value += ' '
				value += content_tag(:span, "", :class => "icon icon-magnifier", :onclick => "$.ajax({url:'#{view_attachment_inline_path(atta.id, preview_tag_id)}', type: 'post'}); $('##{preview_div_id}').toggle();".html_safe )
				value += ' '
				value += content_tag(:span, "(#{number_to_human_size atta.filesize})", :class => "size")
				value += ' '
				value += link_to_attachment atta, class: 'icon-only icon-download', title: l(:button_download), download: true
			  end
			else
			  value = content_tag("i", h(value)) if value
			end
		  end

		  if no_details
			s = l(:text_journal_changed_no_detail, :label => label).html_safe
		  elsif show_diff
			s = l(:text_journal_changed_no_detail, :label => label)
			unless no_html
			  diff_link = link_to 'diff',
				diff_journal_url(detail.journal_id, :detail_id => detail.id, :only_path => options[:only_path]),
				:title => l(:label_view_diff)
			  s << " (#{ diff_link })"
			end
		  elsif detail.value.present?
			case detail.property
			when 'attachment', 'relation'
			  s = l(:text_journal_added, :label => label, :value => value).html_safe + 
			  content_tag(:div, 
			              content_tag(:span, "", :class => "icon icon-close", :onclick => "$('##{preview_div_id}').hide(); $('##{preview_tag_id}').html('');".html_safe) +
			              content_tag(:div, "", :id => preview_tag_id),
			              :id => preview_div_id,
			              :class => "box", 
			              :style => "display: none;"
			  )
			end
		  else
			s = l(:text_journal_deleted, :label => label, :old => old_value).html_safe
		  end
		  s.present? ? s.html_safe : show_detail_without_view_inline(detail, no_html, options)
		end #def   
		     
      end #module
      
    end #module
  end #module
end #module

unless IssuesHelper.included_modules.include?(RedminePreviewInline::Patches::IssuesHelperPatch)
    IssuesHelper.send(:include, RedminePreviewInline::Patches::IssuesHelperPatch)
end
