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
    module AttachmentsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do

          unloadable 
          
          alias_method           :find_attachment_for_inline_preview, :find_attachment
          before_action          :find_attachment_for_inline_preview, :only => [:view_inline]
          before_action          :find_tag_id, :only => [:view_inline]
                    
          layout :choose_layout
          
          def view_inline
            @content = render_to_string :partial => "attachment_iframe", :format => :html
            
            respond_to do |format|
              format.js {}
            end #respond_to
          end #def
          
        private
        
          def find_tag_id
            @tag_id = params[:tag_id].presence
            render_404 unless @tag_id
          end #def
          
          def choose_layout
            if params[:action] == "show" && params[:view_inline].present?
              "view_attachment_inline"
            else
              "base"
            end
          end #def
          
        end #base
      end #self

	  #
	  # disable Redmine's inline/attachment disposition, because
	  # here, we replace the inline disposition with the preview
	  #
	  def disposition(attachment)
# 		if attachment.is_pdf?
# 		  'inline'
# 		else
# 		  'attachment'
# 		end
        'attachment'
	  end

      module InstanceMethods
      end #module
      
    end #module
  end #module
end #module

unless AttachmentsController.included_modules.include?(RedminePreviewInline::Patches::AttachmentsControllerPatch)
    AttachmentsController.send(:include, RedminePreviewInline::Patches::AttachmentsControllerPatch)
end
