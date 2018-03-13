require 'spec_helper'
require 'shared_contexts'

describe 'freeradius::module::eap' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'XXreplace_meXX' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      # ensure: "present",
      # default_eap_type: "md5",
      # timer_expire: "60",
      # ignore_unknown_eap_types: "no",
      # cisco_accounting_username_bug: "no",
      # max_sessions: "${max_requests}",
      # eap_pwd: false,
      # pwd_group: :undef,
      # pwd_server_id: :undef,
      # pwd_fragment_size: :undef,
      # pwd_virtual_server: :undef,
      # gtc_challenge: :undef,
      # gtc_auth_type: "PAP",
      # tls_config_name: "tls-common",
      # tls_private_key_password: :undef,
      # tls_private_key_file: "${certdir}/server.pem",
      # tls_certificate_file: "${certdir}/server.pem",
      # tls_ca_file: "${certdir}/ca.pem",
      # tls_auto_chain: :undef,
      # tls_psk_identity: :undef,
      # tls_psk_hexphrase: :undef,
      # tls_dh_file: "${certdir}/dh",
      # tls_random_file: :undef,
      # tls_fragment_size: :undef,
      # tls_include_length: :undef,
      # tls_check_crl: :undef,
      # tls_check_all_crl: :undef,
      # tls_allow_expired_crl: :undef,
      # tls_ca_path: "${cadir}",
      # tls_check_cert_issuer: :undef,
      # tls_check_cert_cn: :undef,
      # tls_cipher_list: "DEFAULT",
      # tls_disable_tlsv1_2: :undef,
      # tls_ecdh_curve: "prime256v1",
      # tls_cache_enable: "yes",
      # tls_cache_lifetime: "24",
      # tls_cache_max_entries: "255",
      # tls_cache_name: :undef,
      # tls_cache_persist_dir: :undef,
      # tls_verify_skip_if_ocsp_ok: :undef,
      # tls_verify_tmpdir: :undef,
      # tls_verify_client: :undef,
      # tls_ocsp_enable: "no",
      # tls_ocsp_override_cert_url: "yes",
      # tls_ocsp_url: "http://127.0.0.1/ocsp/",
      # tls_ocsp_use_nonce: :undef,
      # tls_ocsp_timeout: :undef,
      # tls_ocsp_softfail: :undef,
      # tls_virtual_server: :undef,
      # ttls_default_eap_type: "md5",
      # ttls_copy_request_to_tunnel: "no",
      # ttls_use_tunneled_reply: "no",
      # ttls_virtual_server: "inner-tunnel",
      # ttls_include_length: :undef,
      # ttls_require_client_cert: :undef,
      # peap_default_eap_type: "mschapv2",
      # peap_copy_request_to_tunnel: "no",
      # peap_use_tunneled_reply: "no",
      # peap_proxy_tunneled_request_as_eap: :undef,
      # peap_virtual_server: "inner-tunnel",
      # peap_soh: :undef,
      # peap_soh_virtual_server: :undef,
      # peap_require_client_cert: :undef,
      # mschapv2_send_error: :undef,
      # mschapv2_identity: :undef,
      # eap_md5: true,
      # eap_leap: true,
      # eap_gtc: true,
      # eap_peap: true,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain_freeradius__module('$name').with(
      ensure: 'present',
      content: [],
    )
  end
  
end
