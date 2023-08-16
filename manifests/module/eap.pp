# @summary Define to configure eap FreeRADIUS module
#
# @param ensure
# @param default_eap_type
# @param timer_expire
# @param ignore_unknown_eap_types
# @param cisco_accounting_username_bug
# @param max_sessions
# @param eap_pwd
# @param pwd_group
# @param pwd_server_id
# @param pwd_fragment_size
# @param pwd_virtual_server
# @param gtc_challenge
# @param gtc_auth_type
# @param tls_config_name
# @param tls_private_key_password
# @param tls_private_key_file
# @param tls_certificate_file
# @param tls_ca_file
# @param tls_auto_chain
# @param tls_psk_identity
# @param tls_psk_hexphrase
# @param tls_dh_file
# @param tls_random_file
# @param tls_fragment_size
# @param tls_include_length
# @param tls_check_crl
# @param tls_check_all_crl
# @param tls_allow_expired_crl
# @param tls_ca_path
# @param tls_check_cert_issuer
# @param tls_check_cert_cn
# @param tls_cipher_list
# @param tls_disable_tlsv1_2
# @param tls_min_version
# @param tls_max_version
# @param tls_ecdh_curve
# @param tls_cache_enable
# @param tls_cache_lifetime
# @param tls_cache_max_entries
# @param tls_cache_name
# @param tls_cache_persist_dir
# @param tls_verify_skip_if_ocsp_ok
# @param tls_verify_tmpdir
# @param tls_verify_client
# @param tls_ocsp_enable
# @param tls_ocsp_override_cert_url
# @param tls_ocsp_url
# @param tls_ocsp_use_nonce
# @param tls_ocsp_timeout
# @param tls_ocsp_softfail
# @param tls_virtual_server
# @param ttls_default_eap_type
# @param ttls_copy_request_to_tunnel
# @param ttls_use_tunneled_reply
# @param ttls_virtual_server
# @param ttls_include_length
# @param ttls_require_client_cert
# @param peap_default_eap_type
# @param peap_copy_request_to_tunnel
# @param peap_use_tunneled_reply
# @param peap_proxy_tunneled_request_as_eap
# @param peap_virtual_server
# @param peap_soh
# @param peap_soh_virtual_server
# @param peap_require_client_cert
# @param mschapv2_send_error
# @param mschapv2_identity
# @param eap_md5
# @param eap_leap
# @param eap_gtc
# @param eap_peap
define freeradius::module::eap (
  String $ensure                                                    = 'present',
  String $default_eap_type                                          = 'md5',
  Integer $timer_expire                                             = 60,
  Freeradius::Boolean $ignore_unknown_eap_types                     = 'no',
  Freeradius::Boolean $cisco_accounting_username_bug                = 'no',
  Freeradius::Integer $max_sessions                                 = "\${max_requests}",
  Boolean $eap_pwd                                                  = false,
  Optional[Variant[String,Integer]] $pwd_group                      = undef,
  Optional[String] $pwd_server_id                                   = undef,
  Optional[Integer] $pwd_fragment_size                              = undef,
  Optional[String] $pwd_virtual_server                              = undef,
  Optional[String] $gtc_challenge                                   = undef,
  String $gtc_auth_type                                             = 'PAP',
  String $tls_config_name                                           = 'tls-common',
  Optional[Freeradius::Password] $tls_private_key_password          = undef,
  String $tls_private_key_file                                      = "\${certdir}/server.pem",
  String $tls_certificate_file                                      = "\${certdir}/server.pem",
  String $tls_ca_file                                               = "\${certdir}/ca.pem",
  Optional[Freeradius::Boolean] $tls_auto_chain                     = undef,
  Optional[String] $tls_psk_identity                                = undef,
  Optional[String] $tls_psk_hexphrase                               = undef,
  String $tls_dh_file                                               = "\${certdir}/dh",
  Optional[String] $tls_random_file                                 = undef,
  Optional[Integer] $tls_fragment_size                              = undef,
  Optional[Freeradius::Boolean] $tls_include_length                 = undef,
  Optional[Freeradius::Boolean] $tls_check_crl                      = undef,
  Optional[Freeradius::Boolean] $tls_check_all_crl                  = undef,
  Optional[Freeradius::Boolean] $tls_allow_expired_crl              = undef,
  String $tls_ca_path                                               = "\${cadir}",
  Optional[String] $tls_check_cert_issuer                           = undef,
  Optional[String] $tls_check_cert_cn                               = undef,
  String $tls_cipher_list                                           = 'DEFAULT',
  Optional[Freeradius::Boolean] $tls_disable_tlsv1_2                = undef,
  Optional[String] $tls_min_version                                 = undef,
  Optional[String] $tls_max_version                                 = undef,
  String $tls_ecdh_curve                                            = 'prime256v1',
  Freeradius::Boolean $tls_cache_enable                             = 'yes',
  Integer $tls_cache_lifetime                                       = 24,
  Integer $tls_cache_max_entries                                    = 255,
  Optional[String] $tls_cache_name                                  = undef,
  Optional[String] $tls_cache_persist_dir                           = undef,
  Optional[Freeradius::Boolean] $tls_verify_skip_if_ocsp_ok         = undef,
  Optional[String] $tls_verify_tmpdir                               = undef,
  Optional[String] $tls_verify_client                               = undef,
  Freeradius::Boolean $tls_ocsp_enable                              = 'no',
  Freeradius::Boolean $tls_ocsp_override_cert_url                   = 'yes',
  String $tls_ocsp_url                                              = 'http://127.0.0.1/ocsp/',
  Optional[Freeradius::Boolean] $tls_ocsp_use_nonce                 = undef,
  Optional[Integer] $tls_ocsp_timeout                               = undef,
  Optional[Freeradius::Boolean] $tls_ocsp_softfail                  = undef,
  Optional[String] $tls_virtual_server                              = undef,
  String $ttls_default_eap_type                                     = 'md5',
  Freeradius::Boolean $ttls_copy_request_to_tunnel                  = 'no',
  Freeradius::Boolean $ttls_use_tunneled_reply                      = 'no',
  String $ttls_virtual_server                                       = 'inner-tunnel',
  Optional[Freeradius::Boolean] $ttls_include_length                = undef,
  Optional[Freeradius::Boolean] $ttls_require_client_cert           = undef,
  String $peap_default_eap_type                                     = 'mschapv2',
  Freeradius::Boolean $peap_copy_request_to_tunnel                  = 'no',
  Freeradius::Boolean $peap_use_tunneled_reply                      = 'no',
  Optional[Freeradius::Boolean] $peap_proxy_tunneled_request_as_eap = undef,
  String $peap_virtual_server                                       = 'inner-tunnel',
  Optional[Freeradius::Boolean] $peap_soh                           = undef,
  Optional[String] $peap_soh_virtual_server                         = undef,
  Optional[Freeradius::Boolean] $peap_require_client_cert           = undef,
  Optional[Freeradius::Boolean] $mschapv2_send_error                = undef,
  Optional[String] $mschapv2_identity                               = undef,
  Boolean $eap_md5                                                  = true,
  Boolean $eap_leap                                                 = true,
  Boolean $eap_gtc                                                  = true,
  Boolean $eap_peap                                                 = true,
) {
  freeradius::module { $name:
    ensure  => $ensure,
    content => template('freeradius/eap.erb'),
  }
}
