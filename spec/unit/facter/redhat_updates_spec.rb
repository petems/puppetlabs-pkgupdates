require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe 'RedHat' do
    context 'returns avaliable updates versions when updates avaliable' do
      before do
        Facter.fact(:osfamily).stubs(:value).returns("RedHat")
        Facter::Util::Resolution.stubs(:exec)
      end
      let(:facts) { {:osfamily => 'RedHat'} }
      it do
        yum_check_updates = <<-EOS

NetworkManager.x86_64                    1:1.0.6-29.el7_2             updates
        EOS
        Facter::Util::Resolution.expects(:exec).with('yum --quiet check-update').returns(yum_check_updates)
        Facter::Util::Resolution.expects(:exec).with('rpm --query --qf \'%{VERSION}-%{RELEASE}\' NetworkManager.x86_64').returns('1.0.6-27.el7')
        expect(Facter.value(:pkg_updates)).to eq({"NetworkManager.x86_64" => {"current"=>"1.0.6-27.el7", "update"=>"1.0.6-29.el7_2"}})
      end
    end

    context 'returns obsolete package versions' do
      before do
        Facter.fact(:osfamily).stubs(:value).returns("RedHat")
        Facter::Util::Resolution.stubs(:exec)
      end
      let(:facts) { {:osfamily => 'RedHat'} }
      it do
        yum_check_updates = <<-EOS

NetworkManager.x86_64                    1:1.0.6-29.el7_2             updates
Obsoleting Packages
PackageKit.x86_64                        1.0.7-5.0.1.el7              ol7_latest
    PackageKit-device-rebind.x86_64      0.8.9-11.0.1.el7             @anaconda/7.1
        EOS
        Facter::Util::Resolution.expects(:exec).with('yum --quiet check-update').returns(yum_check_updates)
        Facter::Util::Resolution.expects(:exec).with('rpm --query --qf \'%{VERSION}-%{RELEASE}\' NetworkManager.x86_64').returns('1.0.6-27.el7')
        Facter::Util::Resolution.expects(:exec).with('rpm --query --qf \'%{VERSION}-%{RELEASE}\' PackageKit.x86_64').returns('1.0.7-5.0.1.el7')
        expect(Facter.value(:pkg_updates)).to eq(
          {"NetworkManager.x86_64"=>{"current"=>"1.0.6-27.el7", "update"=>"1.0.6-29.el7_2"}, "PackageKit.x86_64"=>{"current"=>"1.0.7-5.0.1.el7", "replaced_by"=>{"name"=>"PackageKit-device-rebind.x86_64", "version"=>"0.8.9-11.0.1.el7"}}}
        )
      end
    end

    context 'returns nil when no updates' do
      before do
        Facter.fact(:osfamily).stubs(:value).returns("RedHat")
        Facter::Util::Resolution.stubs(:exec)
      end
      let(:facts) { {:osfamily => 'RedHat'} }
      it do
        Facter::Util::Resolution.expects(:exec).with('yum --quiet check-update').returns(nil)
        expect(Facter.value(:pkg_updates)).to eq(nil)
      end
    end

  end
end
