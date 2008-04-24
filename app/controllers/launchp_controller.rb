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

class LaunchpController < ApplicationController

  layout "densha"

  before_filter :authorize


  #
  # Lists the process definitions this user is allowed to launch.
  #
  def index

    @launch_permissions = LaunchPermission.find_for_user(session[:user])
  end

  #
  # Launches a process instance
  #
  def launch

    user = session[:user]

    lp_id = params[:id]

    lp = begin

        LaunchPermission.find lp_id

    rescue Exception => e

        return error_redirect("launch permission not found")
    end

    if not lp.may_launch(user)
      #
      # preventing URLs from being fed directly to the webapp

      return error_redirect("not authorized to launch : #{lp.url}")
    end

    fei = nil

    begin

      #fei = $openwferu_engine.launch(url)

      li = OpenWFE::LaunchItem.new
      li.workflow_definition_url = lp.real_url
      li.launcher = user.name
      fei = $openwferu_engine.launch li

      flash[:notice] = "launched process '#{fei.workflow_instance_id}'"

      session[:launched_fei] = fei

    rescue Exception => e

      #flash[:notice] = "failed to launch : #{e.to_s}"

      raise e
    end

    sleep 0.777
      #
      # give some time for the engine to proceed and store a potential workitem
      # for this user (the user doing the launch)

    wi = OpenWFE::Extras::Workitem.find_just_launched fei.wfid, user.name

    if wi
      #
      # follow
      #
      redirect_to :controller => :workitem, :action => :edit, :id => wi.id
    else
      #
      # else, stay in the launchp view
      #
      redirect_to :action => :index
    end
  end

end
