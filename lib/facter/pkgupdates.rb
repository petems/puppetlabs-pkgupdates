# Cody Herriges <cody@puppetlabs.com>
#

require 'facter/util/pkgupdates'

updates = Facter::Util::Pkgupdates.get_packages()

Facter.add(:pkg_updates) do
  confine :osfamily => %w{Debian RedHat Solaris}
  confine :operatingsystemrelease => '5.11' if Facter.value(:osfamily) == 'Solaris'
  setcode do
    updates
  end
end
