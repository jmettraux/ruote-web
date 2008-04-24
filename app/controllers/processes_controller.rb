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
# Juan Pedro Paredes
#

class ProcessesController < ApplicationController

  layout "densha"

  before_filter :authorize_admin


  def index

    @status = $openwferu_engine.list_process_status
  end
  
  def cancel_process

    @wfid = params[:id]

    Thread.new do 
        $openwferu_engine.cancel_process @wfid
    end

    #flash[:notice] = "process instance #{@wfid} got cancelled"
    #redirect_to :action => "index"
  end 

  def show_process_errors

    @wfid = params[:id]

    @status = $openwferu_engine.process_status @wfid

    render :partial => "process_errors"
  end

  def replay_at_error

    error_wfei = params[:id]

    wfid, expid = OpenWFE::FlowExpressionId.split_web_s error_wfei

    status = $openwferu_engine.process_status wfid
    error = status.errors.values.find { |err| err.fei.expid == expid }

    $openwferu_engine.replay_at_error error

    #session[:process_errors] = nil

    flash[:notice] = "replayed at error"
    redirect_to :action => "index"
  end

  def pause_process

    pause_resume_process false
  end

  def resume_process

    pause_resume_process true
  end

  def do_in_batch

    action = params[:processes_batch_action]
    wfids = params.keys.find_all { |k| params[k] == "batch" } || []

    method = "#{action}_process".to_sym

    Thread.new do
        wfids.each do |wfid|
            $openwferu_engine.send method, wfid
        end
    end

    sleep 0.777

    flash[:notice] = "sent '#{action}' order to processes #{wfids.join(', ')}"

    redirect_to :action => "index"
  end

  protected

    def pause_resume_process (paused)

      wfid = params[:id]

      if paused
          $openwferu_engine.resume_process(wfid)
      else
          $openwferu_engine.pause_process(wfid)
      end

      sleep 0.200

      #@status = $openwferu_engine.process_status wfid
      #render :partial => "process_state"

      @row_status = $openwferu_engine.process_status wfid
      @row_wfid = wfid
      @row_id = "processes_row_#{@row_wfid}"

      #render :partial => "process_status"
    end

end
