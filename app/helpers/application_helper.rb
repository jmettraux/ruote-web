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

module ApplicationHelper

  #
  # Makes sure the given string can be used as a DOM id.
  #
  def as_id (string)

    string.gsub(" *", "_")
  end

  def omover (elt_id, class_name)

    "$('#{elt_id}').addClassName('#{class_name}')"
  end

  def omout (elt_id, class_name)

    "$('#{elt_id}').removeClassName('#{class_name}')"
  end

  def render_div_clear

    "<div style='clear: both'></div>\n"
  end

  #--
  # The menu methods used in the layout
  #++

  def do_render_menu (menu_items)

    result = menu_items.collect do |i|
      controller_name, action, text, title = i
      if controller.controller_name == controller_name
        text
      else
        link_to(
          text,
          {
            :controller => controller_name,
            :action => action
          },
          {
            :title => title
          })
      end
    end
    result.join(" | ")
  end

  def render_menu

    do_render_menu([
      [ "stores", "index", "view stores", "list stores and workitems available in them" ],
      [ "launchp", "index", "launch process", "start a new business process instance" ],
      [ "engine", "index", "engine", "browse information about the workflow/bpm engine itself" ],
      [ "login", "logout", "logout", "quit this application" ]
    ])
  end

  def render_admin_menu

    "admin " + do_render_menu([
      [ "processes", "index", "processes", "business process engine administration" ],
      [ "worklist", "index", "worklist", "worklist (stores, users, permissions) administration" ]
    ]) + " &nbsp;&nbsp;&nbsp;&nbsp; "
  end

  def store_workitem_buttons (workitem)

    user = session[:user]

    s = ""

    s << link_to(
      "view",
      {
        :controller => "workitem",
        :action => "view",
        :id => workitem.id
      },
      {
        :title => "view workitem and its payload"
      })

    s << "|"

    s << if @worklist.permission(workitem.store_name).may_write? and \
      (not Densha::Locks.is_locked?(user, workitem.id))

      link_to(
        "edit",
        {
          :controller => "workitem",
          :action => "edit",
          :id => workitem.id
        },
        {
          :title => "handle this workitem"
        })
    else
        "<span class='inactive_button' title='cannot edit'>edit</span>"
    end

    s
  end

  #
  #     render_time(workitem, :dispatch_time)
  #         # => Sat Mar 1 20:29:44 2008 (1d16h18m)
  #
  def render_time (object, accessor)

    t = object.send accessor

    return "" unless t

    d = Time.now - t

    "#{t.ctime} (#{Rufus::to_duration_string(d, :drop_seconds => true)})"
  end

  #
  # this method is used in the workitem and process views for workitem or
  # process headers.
  #
  def render_row (class_prefix, key=nil, value=nil, tooltip=nil)

    row_id = if key
      "r" + (key.to_s + value.to_s).hash.to_s
    else
      nil
    end

    unless key
      key = "&nbsp;"
      value = "&nbsp;"
    end

    key = h(key)
    value = h(value)

    s = ""
    s << "<div"
    s << " class='#{class_prefix}_entry'"

    if row_id
      s << " id='#{row_id}'"
      s << " onmouseover=\""+omover(row_id, "#{class_prefix}_entry_over")+"\""
      s << " onmouseout=\""+omout(row_id, "#{class_prefix}_entry_over")+"\""
    end

    s << ">"
    s << "<div class='#{class_prefix}_key'"
    s << " title='#{tooltip}'" if tooltip
    s << ">#{key}</div>"
    s << "<div class='#{class_prefix}_value'>#{value}</div>"
    s << "<div style='clear:both;'></div>"
    s << "</div>"

    s
  end

  #
  # renders a fluo graph (expects to find the procdef in
  # @json_process_definition
  #
  def render_fluo
    <<-EOS
<div id="fluo"></div>
<script>
  Fluo.renderExpression('fluo', null, #{@json_process_definition});
</script>

<br/>
<br/>
<div class="fluo_text">
  #{link_to_function(
    "hide/show minor expressions",
    "Fluo.toggleMinorExpressions('fluo');")}
</div>
    EOS
  end

end
