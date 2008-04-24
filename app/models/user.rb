#
#--
# Copyright (c) 2007, John Mettraux, OpenWFE.org
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

# Strongly inspired by the user example in 
# http://www.pragmaticprogrammer.com/titles/rails/index.html

require 'digest/sha1'


#
# A Densha User.
#
class User < ActiveRecord::Base

    validates_presence_of :name
    validates_uniqueness_of :name

    def validate

      errors.add_to_base("Missing password") if self.hashed_password.blank?
    end

    def User.authenticate (name, password)

      user = self.find_by_name(name)

      if user
          expected_password = hash_password(password, user.salt)
          user = nil if user.hashed_password != expected_password
      end

      user
    end

    def password

      @password
    end

    def password= (p)

      @password = p

      return if p.blank?

      self.salt = self.object_id.to_s + rand.to_s
      self.hashed_password = User.hash_password(self.password, self.salt)
    end

    #
    # Returns true if this user is an admin.
    #
    def admin?

      self.admin
    end

    #
    # Makes sure this User instance can be stored in the session
    # (Removes password information from it).
    #
    def neutralize

      self.hashed_password = nil
      self.salt = nil
    end

    private

        def User.hash_password (password, salt)

          Digest::SHA1.hexdigest(password + "ekimaeni" + salt)
        end
end
