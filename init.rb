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
#
# 1.0.5
#       style adjustments
#
# 1.0.4
#       running also on redmine 5+
#
# 1.0.3
#       running also on redmine 4+
#       
# 1.0.2
#       running on redmine 3.4.11
#       
# 1.0.0
#       running on redmine 3.4.11, never released
#       

require 'redmine'

Redmine::Plugin.register :redmine_preview_inline do
  name 'Redmine Preview Inline'
  author 'Stephan Wenzel'
  description 'This is a plugin for Redmine to preview an attachment inline'
  version '1.0.5'
  url 'https://github.com/HugoHasenbein/redmine_preview_inline'
  author_url 'https://github.com/HugoHasenbein/redmine_preview_inline'
  
  settings :default => {'size'          => '300', # about 3 neighboring previews per page
                        'fullwidth'     => '1'    # use fullwidth preview under thumbnail
                       },
           :partial => 'settings/redmine_preview_inline/settings'
           
end

Rails.configuration.to_prepare do

  # link patches
  require File.expand_path('../lib/redmine_preview_inline/patches/issues_helper_patch', __FILE__)
  require File.expand_path('../lib/redmine_preview_inline/patches/application_helper_patch', __FILE__)
  require File.expand_path('../lib/redmine_preview_inline/patches/attachments_controller_patch', __FILE__)

end

