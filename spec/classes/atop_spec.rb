require 'spec_helper'

describe 'atop' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('atop') }
        it { is_expected.to contain_class('atop::params') }
        it { is_expected.to contain_package('atop').with_ensure('installed') }
        it { is_expected.to contain_service('atop').with_ensure('stopped') }
        it { is_expected.to contain_service('atop').with_enable(false) }
        # Old cron.d file should always be cleaned up
        it { is_expected.to contain_file('/etc/cron.d/atop').with_ensure('absent') }
        # No timers by default
        it { is_expected.not_to contain_service('atop-cleanup.timer') }
        it { is_expected.not_to contain_service('atop-restart.timer') }
      end

      context 'with service enabled' do
        let(:params) do
          {
            service: true,
            interval: 120,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_service('atop').with_ensure('running') }
        it { is_expected.to contain_service('atop').with_enable(true) }
      end

      context 'with keepdays only (no manage_retention)' do
        let(:params) do
          {
            keepdays: 7,
          }
        end

        it { is_expected.to compile.with_all_deps }
        # Should NOT create timer without manage_retention
        it { is_expected.not_to contain_service('atop-cleanup.timer') }
      end

      context 'with manage_retention and keepdays' do
        let(:params) do
          {
            keepdays: 7,
            manage_retention: true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/logrotate.d/atop').with_ensure('absent') }
        it { is_expected.to contain_file('/etc/systemd/system/atop-cleanup.service') }
        it { is_expected.to contain_file('/etc/systemd/system/atop-cleanup.timer') }
        it { is_expected.to contain_service('atop-cleanup.timer').with_ensure('running') }
      end

      context 'with daily_restarts enabled' do
        let(:params) do
          {
            daily_restarts: true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/systemd/system/atop-restart.service') }
        it { is_expected.to contain_file('/etc/systemd/system/atop-restart.timer') }
        it { is_expected.to contain_service('atop-restart.timer').with_ensure('running') }
      end
    end
  end

  context 'on RedHat family' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'CentOS',
          release: { major: '8', minor: '0', full: '8.0' },
        },
        systemd: true,
        puppetversion: '8.0.0',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/sysconfig/atop') }
    it { is_expected.to contain_file('/etc/cron.d/atop').with_ensure('absent') }

    # daily_restarts defaults to false now
    it { is_expected.not_to contain_service('atop-restart.timer') }

    # Puppet 8: should NOT have cron resource (cron type not available)
    it { is_expected.not_to contain_cron('remove_atop') }
  end

  context 'on RedHat family with Puppet 7' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'CentOS',
          release: { major: '8', minor: '0', full: '8.0' },
        },
        systemd: true,
        puppetversion: '7.29.0',
      }
    end

    it { is_expected.to compile.with_all_deps }
    # Puppet 7: should clean up old cron job from crontab
    it { is_expected.to contain_cron('remove_atop').with_ensure('absent') }
  end

  context 'on Debian family' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'Debian',
          release: { major: '11', minor: '0', full: '11.0' },
        },
        systemd: true,
        puppetversion: '8.0.0',
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/etc/default/atop') }
    it { is_expected.to contain_file('/etc/cron.d/atop').with_ensure('absent') }

    # No timers by default
    it { is_expected.not_to contain_service('atop-restart.timer') }
    it { is_expected.not_to contain_service('atop-cleanup.timer') }
  end
end
