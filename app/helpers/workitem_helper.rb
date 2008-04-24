#
#--
# Copyright (c) 2007-2008, John Mettraux, OpenWFE.org
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.  
# 
# . Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# 
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# Made in Japan
#
# john.mettraux@openwfe.org
#

module WorkitemHelper

  #
  # Helpers for the 'workitem' partial
  # (and maybe other partials...)

  def workitem_buttons

    s = ""

    from_view = (request.env['HTTP_REFERER'].match("/view/") != nil)

    s << link_to(
      "back", 
      { :controller => "workitem", :action => "back",
        :id => @workitem.id, :from_view => from_view },
      { :title => "return to the previous page" })

    s << " | "

    s << if @view_only

      if @worklist.permission(@workitem.store_name).may_write? and \
        (not Densha::Locks.is_locked?(session[:user], @workitem.id))

        link_to(
          "edit", 
          { :controller => "workitem", :action => "edit",
            :id => @workitem.id, :from => "view" },
          { :title => "edit this workitem" }) 

      else

        "<span class='inactive_button'>edit</span>"
      end

    else

      html = \
        link_to_function(
          "save", 
          "DenshaHash.doSubmit('save');", 
          :title => "saves the workitem, but don't let it resume in the process for now") +
        " | delegate" +
        " | " +
        link_to_function(
          "proceed", 
          "DenshaHash.doSubmit('proceed');",
          :title => "saves the workitem and make it resume in the process")

      if @workitem.store_name != 'users'
        html += \
         " | " + 
         link_to(
           "pick", 
             { :controller => "workitem", :action => "pick",
               :id => @workitem.id },
             { :title => "pick this workitem and put it into own store" })
      end

      html

      #" | " +
      #link_to_function(
      #  "j", "alert($('workitem').owfeField.getValue().toJSON())")
    end

    s
  end

  TEMPLATE_PREFIX = "#{RAILS_ROOT}/app/views/workitem/_"

  def find_partial (key, default)

    t_name = @workitem.fields_hash[key]

    return default unless t_name

    t_name_view = t_name + "_view"

    if @view_only and File.exist?("#{TEMPLATE_PREFIX}#{t_name_view}.rhtml")
      t_name_view  
    elsif File.exist?("#{TEMPLATE_PREFIX}#{t_name}.rhtml")
      t_name
    else
      default
    end
  end

end
