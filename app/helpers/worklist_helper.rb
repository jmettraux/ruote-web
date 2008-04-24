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

module WorklistHelper

  def render_record_table (classname, records, headers)

    s = form_remote_tag(
      :url => "/worklist/#{classname}/add",
      :html => { :id => "worklist_form_#{classname}" })

    #
    # render headers

    s << render_record(headers)

    #
    # render records

    records.each do |r|

      s << render_record(headers, r)
    end

    s << render_hidden_form(classname, headers)

    s << "</form>\n"

    s
  end

  protected

    def render_record (headers, record=nil)

      s = ""

      ss = if record
        link_to_remote(
          "-", 
          { 
            :url => "/worklist/#{record.class}/delete/#{record.id}",
            :confirm => "are you sure ?" 
          },
          { 
            :title => "removes this element" 
          }
        )
      else
        "&nbsp;"
      end

      s << content_tag(
        :div,
        ss,
        {
          :class => 'stealth_click',
          :style => 'float: left; width: 13px; text-align: center;'
        }
      )

      headers.each do |h|

        text, width = determine_tw(h, record)

        s << render_cell(h(text), width, record)
      end

      s << render_div_clear
    end

    def determine_tw (header, record)

      header = Array(header)

      while header.size < 3
        header << nil
      end

      field, width, text = header

      t = if record
        record.send(field)
      elsif text
        text
      else
        field
      end

      t = t.to_s
      #t = "&nbsp;" if t == ""

      [ t, width ]
    end

    def render_cell (text, width, record=nil)

      text = '&nbsp;' if text == ''

      dclass = "worklist_record_cell"
      dclass += " worklist_record_header" unless record

      style = "float: left;"
      style += " width: #{width}" if width

      content_tag(:div, text, { :class => dclass, :style => style })
    end

    def render_hidden_form (classname, headers)

      fid = "f_#{headers.hash}"
      bid = "b_#{headers.hash}"

      s = "<div id='#{fid}' style='display: none;'>"

      s << content_tag(
        :div,
        "&nbsp;",
        {
          :class => 'stealth_click',
          :style => 'font-size: xx-small; float: left; width: 13px; text-align: center;'
        }
      )

      headers.each do |header|

        header = Array(header)

        field = header[0]
        width = header[1]

        t = tag(
          :input,
          {
            :class => 'worklist_string_input',
            :type => 'text',
            :name => field,
            :value => 'new'
          }
        )

        s << render_cell(t, width)
      end

      # should clean that, but it's ok for now

      s << "<div "
      s << "class='stealth_click' "
      s << "style='font-size: x-small; float: left; text-align: center;' "
      s << ">"
      s << "<a href='#' "
      s << "title='add this new element' "
      s << "onclick='$(\"worklist_form_#{classname}\").onsubmit(); return false;'"
      s << ">+</a>"
      s << "<br/>"
      s << "<a href='#' "
      s << "title='cancel addition of the new element' "
      s << "onclick='toggleWadminAddButton(\"#{fid}\", \"#{bid}\"); return false;'"
      s << ">x</a>"
      s << "</div>\n"

      #s << render_div_clear

      s << "</div>\n"


      s << "<div "
      s << "id='#{bid}' "
      s << "class='stealth_click' "
      s << "style='font-size: xx-small; width: 13px; text-align: center;'>"

      s << "<a href='#' "
      s << "title='add a new element' "
      s << "onclick='toggleWadminAddButton(\"#{fid}\", \"#{bid}\"); return false;'"
      s << ">+</a>"

      #s << "<script>toggleWadminAddButton('#{fid}', '#{bid}');</script>"

      s << "</div>"
      s
    end
end

