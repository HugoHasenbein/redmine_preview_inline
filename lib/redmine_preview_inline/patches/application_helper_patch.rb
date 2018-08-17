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
    module ApplicationHelperPatch

      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do

          unloadable 
          alias_method_chain :thumbnail_tag, :inline_view
          
          def attachment_inline_view_tag(content, attachment)
          
           preview_pane_id   = SecureRandom.uuid.to_s.gsub(/\-/, "_") 
           preview_tag_id    = SecureRandom.uuid.to_s.gsub(/\-/, "_") 

		   # load selector (magnifying glass icon with all parameters)
		   erb = ERB.new(File.read(File.join(__dir__, '..', '..', '..', 'app', 'views', 'attachments', '_thumbnail_inline_view_selector.html.erb')))
		   selector_html = erb.result(binding)
           
           width_param = json_escape(Setting['plugin_redmine_preview_inline']['size']).presence || "300"
           
           # load inline view pane
           erb = ERB.new(File.read(File.join(__dir__, '..', '..', '..', 'app', 'views', 'attachments', '_thumbnail_inline_view_pane.html.erb')))
           view_pane_html = erb.result(binding)
           
           # add all together
           content + selector_html.html_safe + view_pane_html.html_safe

          end #def

        end #base

      end #self


      module InstanceMethods    

          # ------------------------------------------------------------------------------#
          # creates a thumbnail tag, which honors
          # the attachment_category
          # ------------------------------------------------------------------------------#
          def thumbnail_tag_with_inline_view(attachment, options={})
             if options.delete(:no_inner_view_pane)
               
               preview_pane_id = options[:preview_pane_id]  # the whole pane
               preview_tag_id  = options[:preview_tag_id]   # where the preview is located within the inline view pane
               
               # load selector (magnifying glass icon with all parameters)
               erb = ERB.new(File.read(File.join(__dir__, '..', '..', '..', 'app', 'views', 'attachments', '_thumbnail_inline_view_selector.html.erb')))
               selector_html = erb.result(binding)
               
               # thumbnail and add inline view selector
               # the inline view pane will be handled by the caller 
               thumbnail_tag_without_inline_view(attachment) + selector_html.html_safe
               
             else #inner view pane (standard)
               attachment_inline_view_tag(thumbnail_tag_without_inline_view(attachment), attachment)
             end
          end

       end #module
      
       module ClassMethods

       end #module
      
    end #module
  end #module
end #module

unless ApplicationHelper.included_modules.include?(RedminePreviewInline::Patches::ApplicationHelperPatch)
    ApplicationHelper.send(:include, RedminePreviewInline::Patches::ApplicationHelperPatch)
end


