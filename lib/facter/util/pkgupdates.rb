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
      lines = Facter::Util::Resolution.exec(command).split("\n").drop(1)
      lines.each do |pkg|
        list = pkg.split(/ +/)
        updates[list[0]] = {}
        updates[list[0]]['current'] = Facter::Util::Resolution.exec("rpm --query --qf '%{VERSION}-%{RELEASE}' #{list[0]}")
        updates[list[0]]['update'] = list[1].split(':')[-1]
      end
    when 'Solaris'
      command = 'pkg list -u -H'
      lines = Facter::Util::Resolution.exec(command).split("\n")
      lines.each do |pkg|
        list = pkg.split(/ +/)
        updates[list[0]] = {}
        updates[list[0]]['current'] = list[1]
        updates[list[0]]['update'] = Facter::Util::Resolution.exec("pkg info -r #{list[0]}").scan(/Version: (.*)/)[0][0]
      end
    end
    return updates
  end
end
