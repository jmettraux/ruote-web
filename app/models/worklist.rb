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
# "made in Japan"
#
# John Mettraux at openwfe.org
# 

unless defined? RWD_STORE_PERMISSION

  RWD_STORE_PERMISSION = Object.new

  class << RWD_STORE_PERMISSION
    def permission
      "rwd"
    end
    def may_read?
      true
    end
    def may_write?
      true
    end
    def may_delegate?
      true
    end
  end
end


#
# This is not an ActiveRecord model, there are no 'worklist' 'records',
# this is just a gathering of methods leveraging one or more base models,
# they thus constitute a 'worklist'.
#
class Worklist

  def initialize (user)

    @user = user

    @permissions = find_permissions
    @store_names = find_store_names

    @workitems = OpenWFE::Extras::Workitem.find_in_stores @store_names
  end

  #
  # Lists the names of the store this user is entitled to read or write to.
  #
  def store_names

    names = @store_names.dup
    names << "users" unless names.include?("users")
    names
  end

  #
  # Returns the permission for the given store.
  #
  def permission (store_name)

    return RWD_STORE_PERMISSION if @user.admin?
    return RWD_STORE_PERMISSION if store_name == 'users'
    @permissions[store_name]
  end

  #
  # Returns the workitems for the given store.
  #
  def workitems (store_name)

    return load_user_workitems if store_name == 'users'

    @workitems[store_name] || []
  end

  #
  # Returns the list of store[ names]s to which the user can delegate.
  #
  # If a workitem is passed, makes sure to remove the workitem current
  # store name from the resulting list.
  #
  def delegation_targets (workitem=nil)

    names = @store_names.find_all { |n| permission(n).may_delegate? }

    names.delete(workitem.store_name) if workitem

    names
  end

  #
  # Given a search string, returns all the matching workitems
  # (in the stores in which the user can read).
  #
  def search (query_string)

    OpenWFE::Extras::Workitem.search(query_string, store_names).find_all do |wi|

      @user.admin? or (
        wi.store_name != 'users' || wi.participant_name == @user.name)
    end
  end

  protected

    def load_user_workitems

      return OpenWFE::Extras::Workitem.find_all_by_store_name('users') \
        if @user.admin?

      OpenWFE::Extras::Workitem.find_all_by_store_name_and_participant_name(
        'users', @user.name)
    end

    #
    # Returns all the store names (according to the 'wi_stores' table)
    #
    def find_all_storenames

      WiStore.find(:all).collect do |store|
        store.name
      end
    end

    #
    # Returns the mapping "storename" -> Permission instance
    #
    def find_permissions

      return nil if @user.admin?

      groupnames = Group.find_groups(@user)

      StorePermission.find_all_by_groupname(groupnames).inject({}) do 
        |result, permission|

        result[permission.storename] = permission
        result
      end
    end

    #
    # Returns a list of Store instances.
    #
    def find_store_names

      if @user.admin?
        find_all_storenames
      else
        @permissions.keys.sort
      end
    end

end

