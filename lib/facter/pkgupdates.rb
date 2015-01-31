# Cody Herriges <cody@puppetlabs.com>
#

require 'facter/util/pkgupdates'

updates = Facter::Util::Pkgupdates.get_packages()

Facter.add(:pkg_updates) do
  confine :operatingsystem => %w{Debian RedHat}
  setcode do
    updates
  end
end
