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

require 'openwfe/engine/file_persisted_engine' # gem 'openwferu'
require 'openwfe/extras/participants/activeparticipants' # gem 'openwferu-extras'

#
# adding a rails_url method to FlowExpressionId

class OpenWFE::FlowExpressionId

  def rails_url

    url = self.workflow_definition_url

    if url.match("^public/")
      url[6..-1]
    else
      url
    end
  end
end

#
# Opening the class to add some helper methods
#
class OpenWFE::Extras::Workitem

  #
  # Returns a nicer representation of the FlowExpressionId identifier
  # for this workitem
  #
  def fei_to_s

    ffei = self.full_fei

    "#{ffei.wfid} #{ffei.expname} #{ffei.expid} - " +
    "#{ffei.wfname} #{ffei.wfrevision}"
  end

  #
  # Returns the activity (string) if set in the 'params' of the workitem.
  #
  def activity

    params = fields_hash["params"]
    return nil unless params
    params["activity"]
  end
end


module Densha

  #
  # A custom densha participant map, which provides a 'fallback'
  # participants for the 'users' store.
  #
  # Any workitem with an unknown participant will be routed to this user
  # store if there is a store, if the user name corresponds to the
  # participant name for the workitem.
  #
  class ParticipantMap < OpenWFE::ParticipantMap

    def initialize (service_name, application_context)

      super

      @user_store = OpenWFE::Extras::ActiveStoreParticipant.new 'users'
    end

    def lookup_participant (participant_name)

      p = super

      return p if p

      u = User.find_by_name participant_name

      return nil unless u

      @user_store
    end
  end

  class Engine < OpenWFE::CachedFilePersistedEngine

    #
    # Reloads the store participants as participants to the engine.
    # Returns how many store participants were [re]registered.
    #
    def reload_store_participants

      stores = []
      begin
        stores = WiStore.find(:all)
      rescue Exception => e
      end

      stores.each do |store|
        register_participant(
          store.regex,
          OpenWFE::Extras::ActiveStoreParticipant.new(store.name))
      end

      stores.size
    end

    protected

      def build_participant_map

        init_service :s_participant_map, ParticipantMap
      end
  end

end

