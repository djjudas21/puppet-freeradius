RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

# Set up freeradius::params with the redhat values, so we have something
# to test for in the freeradius spec without defining separate tests for
# every OS
shared_context 'redhat_params' do
  let(:pre_condition) do
    [
      'class freeradius::params {
        $fr_basepath = "/etc/raddb"
        $fr_configdir = "mods-config"
        $fr_db_dir = "\${localstatedir}/lib/radiusd"
        $fr_group = "radiusd"
        $fr_libdir = "/usr/lib64/freeradius"
        $fr_logpath = "/var/log/radius"
        $fr_moduleconfigpath = "/etc/raddb/mods-config"
        $fr_moduledir = "mods-enabled"
        $fr_modulepath = "/etc/raddb/mods-enabled"
        $fr_package = "freeradius"
        $fr_pidfile = "/var/run/radiusd/radiusd.pid"
        $fr_raddbdir = "\${sysconfdir}/raddb"
        $fr_service = "radiusd"
        $fr_service_has_status = true
        $fr_user = "radiusd"
        $fr_version = "3"
        $fr_wbpriv_user = "wbpriv"
        $fr_wpa_supplicant = "wpa_supplicant"
        $radacctdir = "\${logdir}/radacct"
      }'
    ]
  end
end

# Set up a default freeradius instance, so we can test other classes which
# require freeradius to exist first
shared_context 'freeradius_default' do
  let(:pre_condition) do
    [
      'class { freeradius: }'
    ]
  end
end
