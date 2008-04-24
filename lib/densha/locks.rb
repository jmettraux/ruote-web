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


module Densha

  #
  # All about locking workitems.
  # This lock system currently uses global variables, it's all stored in memory
  # locks are not preserved at restart.
  #
  class Locks
  
    unless defined? $workitem_locks
      $workitem_locks = {} 
      $workitem_locks_mutex = Mutex.new
    end
  
    #
    # A Lock class
    #
    class Lock
  
      attr_reader :user, :since
  
      def initialize (locker)
        @user = locker
        @since = Time.now
      end
  
      def delta (now)
        now - @since.to_f
      end
  
      def to_s
        "Lock : '#{@user.name}' since #{@since}"
      end
    end
  
    #
    # Sets on lock for a workitem (and for a given user).
    #
    def Locks.lock_workitem (user, workitem_id)
  
      return false if is_locked?(user, workitem_id)
  
      $workitem_locks_mutex.synchronize do
  
        $workitem_locks[Integer(workitem_id)] = Lock.new(user)
      end
  
      true
    end
  
    #
    # Considers each lock currently set, will remove any that should time out
    # (that is set since a time in second larger than what the 
    # lock_max_age() method returns).
    #
    def Locks.review_locks
  
      $workitem_locks_mutex.synchronize do
  
        now = Time.now.to_f
  
        $workitem_locks.keys.each do |workitem_id|
  
          delta = $workitem_locks[Integer(workitem_id)].delta(now)
  
          $workitem_locks.delete(workitem_id) if delta > lock_max_age
        end
      end
    end
  
    #
    # Returns the number of seconds a lock should be held on a workitem.
    #
    def Locks.lock_max_age
  
      (10 * 60) # 10 minutes
    end
  
    #
    # Unlocks the workitem, if the lock is held by another user than the one
    # given, this call will have no effect.
    #
    def Locks.unlock_workitem (user, workitem_id, force=false)
  
      $workitem_locks_mutex.synchronize do
  
        workitem_id = Integer(workitem_id)
  
        lock = $workitem_locks[workitem_id]
  
        return unless lock
  
        unless force
          return if lock.user.name != user.name
        end
  
        $workitem_locks.delete workitem_id
      end
    end
  
    #
    # Returns false if there is no lock on the given workitem or if the
    # workitem is locked by the given (current) user.
    #
    def Locks.is_locked? (user, workitem_id)
  
      lock = $workitem_locks[Integer(workitem_id)]
  
      return false unless lock
  
      (lock.user.name != user.name)
    end
  
    #
    # Returns true if the workitem is locked and the user is the owner of 
    # the lock.
    #
    # 'owns' or 'own' ?
    #
    def Locks.owns_lock? (user, workitem_id)
  
      lock = $workitem_locks[Integer(workitem_id)]

      return false unless lock

      (lock.user.name == user.name)
    end
  
    #
    # Returns a human friendly view on the current locks.
    #
    def Locks.to_s
  
      s = $workitem_locks.collect do |workitem_id, lock|
        "- #{workitem_id}  -  #{lock.to_s}"
      end
  
      s.join "\n"
    end
  end
end

