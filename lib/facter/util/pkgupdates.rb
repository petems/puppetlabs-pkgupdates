# Cody Herriges <cody@puppetlabs.com>
#
module Facter::Util::Pkgupdates
  def self.get_packages
    updates = {}
    case Facter.value(:osfamily)
    when 'Debian'
      command = 'apt-get -s dist-upgrade | grep "Inst "'
      lines = Facter::Util::Resolution.exec(command)
      if ! lines.nil?
        lines.split("\n").each do |pkg|
          name = pkg.scan(/^Inst (.*?) /)[0][0]
          updates[name] = {}
          begin
            updates[name]['current'] = pkg.scan(/#{name} \[(.*?)\]/)[0][0]
          rescue
            updates[name]['current'] = 'not installed'
          end
          updates[name]['update'] = pkg.scan(/\((.*?) /)[0][0]
        end
      end
    when 'RedHat'
      command = 'yum --quiet check-update'
      lines = Facter::Util::Resolution.exec(command).split("\n").drop(1)
      lines.each do |pkg|
        list = pkg.split(/ +/)
        updates[list[0]] = {}
        updates[list[0]]['current'] = Facter::Util::Resolution.exec("rpm --query --qf '%{VERSION}-%{RELEASE}' #{list[0]}")
        updates[list[0]]['update'] = list[1].split(':')[-1]
      end
    when 'Solaris'
      command = 'pkg list -u -H'
      lines = Facter::Util::Resolution.exec(command)
      if lines
        split_lines = lines.split("\n")
        split_lines.each do |pkg|
          list = pkg.split(/ +/)
          updates[list[0]] = {}
          updates[list[0]]['current'] = list[1]
          updates[list[0]]['update'] = Facter::Util::Resolution.exec("pkg info -r #{list[0]}").scan(/Version: (.*)/)[0][0]
        end
      end
    end
    return updates if updates.length != 0
  end
end
