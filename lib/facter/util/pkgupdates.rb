# Cody Herriges <cody@puppetlabs.com>
#
module Facter::Util::Pkgupdates
  def self.get_packages
    updates = {}
    case Facter.value(:osfamily)
    when 'Debian'
      command = 'apt-get -s dist-upgrade | grep Inst'
      Facter::Util::Resolution.exec(command).split("\n").each do |pkg|
        list = pkg.split(" ")
        updates[list[1]] = {}
        updates[list[1]]['current'] = list[2].scan(/\[(.*)\]/)[0][0]
        updates[list[1]]['update'] = list[3].scan(/\((.*)/)[0][0]
      end
    when 'RedHat'
      command = 'yum --quiet check-upgrade'
      Facter::Util::Resolution.exec(command).split("\n").each do |pkg|
        list = pkg.split("\t")
        updates[list[1]] = {}
        updates[list[1]]['current'] = Facter::Util::Resolution.exec("rpm --query --qf '%{VERSION}-%{RELEASE}' #{list[1]}")
        updates[list[1]]['update'] = list[2]
      end
    end
    return updates
  end
end
