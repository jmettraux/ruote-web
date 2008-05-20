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

class LaunchPermission < ActiveRecord::Base

  #
  # Returns the real_url, the one as seen from the rails application.
  #
  def real_url

    if url[0, 1] == "/"
      #File.expand_path(RAILS_ROOT + "/public" + url)
      "public" + url
    else
      url
    end
  end

  #
  # Returns true if the user is entitled this launch permission.
  #
  def may_launch (user)

    permissions = LaunchPermission.find_for_user(user)

    permissions.include?(self)
  end

  #
  # Returns all the launch permissions available to a given user.
  #
  def LaunchPermission.find_for_user (user)

    result = if user.admin?

      find(:all)
    else

      groupnames = Group.find_groups(user)
      groupnames << ""
        # launch URLs with a "" groupname are launchable by anybody

      find_all_by_groupname(groupnames)
    end

    result.sort_by { |lp| lp.url }
  end

  #
  # Given a real url (like found in a fei), will return the first
  # launch permission that bears the corresponding (not real) url.
  #
  def LaunchPermission.find_by_real_url (url)

    url = from_real_url(url)
    find_by_url(url)
  end

  #--
  # Only allow to view (yes, view) definition URLs for which there is a
  # permission.
  #
  #def LaunchPermission.may_view (url)
  #  url = url[6..-1] if url.match("^public")
  #  (find_by_url(url) != nil)
  #end
  #++

  #
  # Reads the process definition from its URL and returns it as well
  # as the process representation of it (the representation is used for
  # the 'fluo' rendering, it's a JSON string).
  #
  def load_process_definition

    pdef, prep = load_process_def

    [ pdef, prep.to_a.to_json ]
  end

  #
  # Loads the process definition and return the description of the process
  # or nil if there is none.
  #
  def get_description

    pdef, prep = load_process_def

    OpenWFE::ExpressionTree.get_description prep
  end

  #
  # Given a URL returns the process definition (and the json representation
  # of it).
  # This method is used to display the process definition graph alongside
  # the workitem.
  #
  def LaunchPermission.load_process_definition (url)

    lp = find_by_url(from_real_url(url))

    return nil unless lp

    lp.load_process_definition
  end

  #
  # Makes sure the given url is translated to a launch permission url.
  #
  def LaunchPermission.from_real_url (url)

    if url.match("^public/")
      url[6..-1]
    else
      url
    end
  end

  private

    def load_process_def

      pdef = open(real_url).readlines.join("\n")
      prep = OpenWFE::DefParser.parse pdef

      [ pdef, prep ]
    end
end

