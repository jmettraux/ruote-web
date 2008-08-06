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


class DefinitionController < ApplicationController

  layout "densha"

  before_filter :authorize


  #
  # A view on the process definition.
  #
  def index

    lp_id = params[:id]
    @defurl = params[:defurl]

    @lp = if lp_id
      LaunchPermission.find_by_id lp_id
    else
      LaunchPermission.find_by_real_url @defurl
        # will return the first perm with that URL, not the one for this
        # user, but it doesn't matter, we just need the load_process_definition
        # method.
    end

    @defurl = @lp.real_url

    return error_redirect("couldn't find process at #{lp_id} / #{@defurl}") \
        unless @lp

    begin
      #
      # reading the process definition, if possible...

      @process_definition, @json_process_definition =
        @lp.load_process_definition

    rescue Exception => e

      return error_redirect "couldn't parse process definition at #{@defurl}"
    end

    ref = request.env['HTTP_REFERER']
    @from_launch = ref ? ref.match("/launchp$") : ""

    @is_xml = @process_definition.strip[0, 1] == "<"
  end

end
