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
      check_update_output = Facter::Util::Resolution.exec(command)
      if check_update_output
        lines = check_update_output.split("\nObsoleting Packages\n")[0].split("\n").drop(1)
        if check_update_output.include?("\nObsoleting Packages\n")
          obsolete_packages = check_update_output.split("\nObsoleting Packages\n")[1].split("\n").each_slice(2)
        end
        lines.each do |pkg|
          list = pkg.split(/ +/)
          updates[list[0]] = {}
          updates[list[0]]['current'] = Facter::Util::Resolution.exec("rpm --query --qf '%{VERSION}-%{RELEASE}' #{list[0]}")
          updates[list[0]]['update'] = list[1].split(':')[-1]
        end

        if obsolete_packages
          obsolete_packages.each do | obs_pkg |
            obs_list = obs_pkg[0].split(/ +/)
            replacement_list = obs_pkg[1].split(/ +/)
            updates[obs_list[0]] = {}
            updates[obs_list[0]]['current'] = Facter::Util::Resolution.exec("rpm --query --qf '%{VERSION}-%{RELEASE}' #{obs_list[0]}")
            updates[obs_list[0]]['replaced_by'] = {}
            updates[obs_list[0]]['replaced_by']['name'] = replacement_list[1]
            updates[obs_list[0]]['replaced_by']['version'] = replacement_list[2]
          end
        end
      end
    when 'Solaris'
      if system('pkg list -u -H > /dev/null 2>&1')
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
    end
    return updates if updates.length != 0
  end
end
