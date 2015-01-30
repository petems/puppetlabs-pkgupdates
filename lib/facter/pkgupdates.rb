# Cody Herriges <cody@puppetlabs.com>
#

require 'facter/util/pkgupdates'

data = {}

data['updates'], data['security'] = Facter::Util::Pkgupdates.get_packages()

data.each do |type, pkgs|
  Facter.add(:"pkg_#{type}") do
    confine :operatingsystem => %w{Debian}
    setcode do
      pkgs
    end
  end
end

