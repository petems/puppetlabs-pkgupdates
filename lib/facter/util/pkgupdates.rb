# Cody Herriges <cody@puppetlabs.com>
#
module Facter::Util::Pkgupdates
  def self.get_packages
    updates = {}; security = {}
    case Facter.value(:osfamily)
    when 'Debian'
      command = 'apt-get -s dist-upgrade | grep -e Inst'
      updates = {}; security = {}
      Facter::Util::Resolution.exec(command).split("\n").each do |pkg|
        if pkg.match("Debian-Security")
          list = pkg.split(" ")
          security[list[1]] = {}
          security[list[1]]['current'] = list[2].scan(/\[(.*)\]/)[0][0]
          security[list[1]]['update'] = list[3].scan(/\((.*)/)[0][0]
        else
          list = pkg.split(" ")
          updates[list[1]] = {}
          updates[list[1]]['current'] = list[2].scan(/\[(.*)\]/)[0][0]
          updates[list[1]]['update'] = list[3].scan(/\((.*)/)[0][0]
        end
      end
    end
    return updates, security
  end
end
