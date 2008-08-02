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

class WorkitemController < ApplicationController

  layout "densha"

  before_filter :authorize

  #FIELD_REX = Regexp.compile "^workitem\_form\_field\_(.*)"
  FIELD_REX = Regexp.compile "^hash\_form\_field\_(.*)"

  #
  # opens a workitem in edition mode
  #
  def edit

    wid = get_wid or return

    load_workitem wid
  end

  #
  # picks the workitem (users places it into its own workitem store).
  #
  def pick

    wid = get_wid or return

    pick_workitem wid

    redirect_to :controller => "stores"
  end

  #
  # opens a workitem in view-only mode
  #
  def view

    @view_only = true

    wid = params[:id]

    return error_wi_not_found \
      unless OpenWFE::Extras::Workitem.exists?(wid)

    load_workitem wid

    render :template => "workitem/edit"
  end

  #
  # saves or proceeds the workitem
  #
  def update

    user = session[:user]
    workitem_id = session[:workitem]

    workitem = OpenWFE::Extras::Workitem.find workitem_id

    action = params[:hash_form_action]
    store_name = params[:store_name]

    return error_wi_not_owner(action) \
      unless Densha::Locks.owns_lock?(user, workitem.id)

    json = params[:hash_form_json]

    if json

      fields = ActiveSupport::JSON.decode(json)
        #
        # take the workitem payload as a whole via json

      params.keys.each do |k|
        sk = k.to_s
        m = FIELD_REX.match sk
        next unless m
        fields[m[1]] = params[k]
      end
        #
        # gather the 'hash_form_field_X' form entries as well

    else
      #
      # there is no json, assume that form parameters are the requested
      # fields

      fields = params
    end

    fields['last_modified_by'] = user.name

    workitem.store_name = store_name if action == 'delegate'

    workitem.touch # setting last_modified to now

    #
    # injecting fields as updated by the user...

    current_fields, hidden_fields = filter_fields workitem

    fields = fields.merge hidden_fields

    workitem.replace_fields fields # calls workitem.save!

    #
    # just do it...

    if (action == 'save')

      #workitem.save!
        # already performed by replace_fields

      flash[:notice] = "workitem got saved."

    elsif (action == 'delegate')

      flash[:notice] = "workitem got delegated to store #{store_name}"

    else # action is 'proceed'

      $openwferu_engine.proceed workitem

      sleep 0.250 # ;-)

      flash[:notice] = "workitem got proceeded."
    end

    Densha::Locks.unlock_workitem user, workitem.id

    return_to_previous_page
  end

  #
  # The 'back' function of the edit/view workitem pages.
  #
  def back

    workitem_id = params[:id]

    Densha::Locks.unlock_workitem(session[:user], workitem_id) if workitem_id

    session[:workitem] = nil

    return_to_previous_page
  end

  #def delegate
  #end

  protected

    def get_wid

      wid = params[:id]

      unless OpenWFE::Extras::Workitem.exists?(wid)
        error_wi_not_found
        return nil
      end

      unless Densha::Locks.lock_workitem(session[:user], wid)
        error_wi_locked
        return nil
      end

      wid
    end

    #
    # Returns to the previous page
    #
    def return_to_previous_page

      if params[:from_view]

        redirect_to(
          :controller => "workitem", :action => "view", :id => params[:id])

      else

        redirect_to :controller => "stores"
      end
    end

    def error_wi_not_found

      flash[:notice] = "workitem not found"

      redirect_to :controller => "stores"
    end

    def error_wi_locked

      flash[:notice] = "workitem already locked"

      redirect_to :controller => "stores"
    end

    def error_wi_not_owner (action)

      flash[:notice] = "can't #{action}, not owner of lock"

      redirect_to :controller => "stores"
    end

    #
    # filters out fields starting with an _, returns two hashes,
    # the first of fields whose name doesn't begin with "_", and the second ...
    #
    def filter_fields (workitem)

      fields_in, fields_out = workitem.fields_hash.partition do |k, v|
        k[0, 1] != '_'
      end

      [ a_to_h(fields_in), a_to_h(fields_out) ]
    end

    #
    # Loads a workitem, given its id, and takes care of separating
    # uninteresting fields (not to be touched by users), and stores
    # the workitem as well in the session.
    #
    def load_workitem (workitem_id)

      @worklist = Worklist.new(session[:user])

      @workitem = OpenWFE::Extras::Workitem.find workitem_id

      @delegation_targets = @worklist.delegation_targets(@workitem)

      @fields, hidden_fields = filter_fields @workitem

      session[:workitem] = @workitem.id


      #@process_definition, @json_process_definition =
      #  LaunchPermission.load_process_definition(
      #      @workitem.full_fei.workflow_definition_url)

      pwfid = @workitem.full_fei.parent_wfid

      @json_process_definition =
        $openwferu_engine.process_representation(pwfid).to_json.to_s

      @paused = $openwferu_engine.is_paused?(pwfid)
        # a small digression (out of the worklist, into the engine)
    end

    #
    # The workitem gets 'picked' by the current user.
    # It thus gets placed in the "users" workitem stores, available
    # for the user.
    #
    def pick_workitem (workitem_id)

      user = session[:user]

      workitem = OpenWFE::Extras::Workitem.find workitem_id

      workitem.store_name = "users"
      workitem.participant_name = user.name
      workitem.save!
    end

    #
    # Array to Hash (wondering why I have to write it by myself... but it's
    # fun, maybe someone will point me to something in ActiveSupport...)
    #
    def a_to_h (a)

      a.inject({}) { |r, e| r[e.first] = e.last; r }
    end

end
