RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

# Set up a default freeradius instance, so we can test other classes which
# require freeradius to exist first
shared_context 'freeradius_default' do
  let(:pre_condition) do
    [
      'class { "freeradius": }',
    ]
  end
end

# Same as above but enable utils
shared_context 'freeradius_with_utils' do
  let(:pre_condition) do
    [
      'class { "freeradius":
        utils_support => true,
      }',
    ]
  end
end

def freeradius_settings_hash(os_facts)
  osfamily        = os_facts[:osfamily]
  operatingsystem = os_facts[:operatingsystem]
  freeradius = {}
  case osfamily
  when 'Debian'
    freeradius[:wpa_supplicant_package_name] = 'wpasupplicant'
    freeradius[:service_name] = case operatingsystem
                                when 'Ubuntu'
                                  'radiusd'
                                else
                                  'freeradius'
                                end
    freeradius[:service_has_status] = true
    freeradius[:basepath] = case operatingsystem
                            when 'Ubuntu'
                              '/etc/raddb'
                            else
                              '/etc/freeradius/3.0'
                            end
    freeradius[:raddbdir] = case operatingsystem
                            when 'Ubuntu'
                              '${sysconfdir}/raddb'
                            else
                              '${sysconfdir}/freeradius/3.0'
                            end
    freeradius[:logpath] = case operatingsystem
                           when 'Ubuntu'
                             '/var/log/radius'
                           else
                             '/var/log/freeradius'
                           end
    freeradius[:user] = case operatingsystem
                        when 'Ubuntu'
                          'radiusd'
                        else
                          'freerad'
                        end
    freeradius[:group] = case operatingsystem
                         when 'Ubuntu'
                           'radiusd'
                         else
                           'freerad'
                         end
    freeradius[:wbpriv_user] = 'winbindd_priv'
    freeradius[:libdir] = case operatingsystem
                          when 'Ubuntu'
                            '/usr/lib64/freeradius'
                          else
                            '/usr/lib/freeradius'
                          end
    freeradius[:db_dir] = case operatingsystem
                          when 'Ubuntu'
                            '${localstatedir}/lib/radiusd'
                          else
                            '${raddbdir}'
                          end
    freeradius[:radsniff] = {
      envfile: '/etc/defaults/radsniff',
      pidfile: "/var/run/#{freeradius[:service_name]}/radsniff.pid"
    }
  else
    freeradius[:wpa_supplicant_package_name] = 'wpa_supplicant'
    freeradius[:service_name] = 'radiusd'
    freeradius[:service_has_status] = false
    freeradius[:basepath] = '/etc/raddb'
    freeradius[:raddbdir] = '${sysconfdir}/raddb'
    freeradius[:logpath] = '/var/log/radius'
    freeradius[:user] = 'radiusd'
    freeradius[:group] = 'radiusd'
    freeradius[:wbpriv_user] = 'wbpriv'
    freeradius[:libdir] = '/usr/lib64/freeradius'
    freeradius[:db_dir] = '${localstatedir}/lib/radiusd'
    freeradius[:radsniff] = {
      envfile: '/etc/sysconfig/radsniff',
      pidfile: "/var/run/#{freeradius[:service_name]}/radsniff.pid"
    }
  end
  freeradius
end
