# @summary Define to configure eap FreeRADIUS module
#
# @param ensure
#   If the module should `present` or `absent`.
# @param default_eap_type
#   Default EAP type.
# @param timer_expire
#   How much time an entry is maintained in the list to correlate EAP-Response packets with EAP-Request packets.
# @param ignore_unknown_eap_types
#   By setting this options to `yes`, you can tell the server to keep processing requests with an EAP type it does not support.
# @param cisco_accounting_username_bug
#   Enables a work around to handle Cisco AP1230B firmware bug.
# @param max_sessions
#   Maximum number of EAP sessions the server tracked.
# @param eap_pwd
#   If set to `true` configures EAP-pwd authentication.
# @param pwd_group
#   `group` used in pwd configuration.
# @param pwd_server_id
#   `server_id` option in pwd configuration.
# @param pwd_fragment_size
#   `fragment_size` option in pwd configuration.
# @param pwd_virtual_server
#   The virtual server which determines the "known good" password for the user in pwd authentication.
# @param gtc_challenge
#   The default challenge.
# @param gtc_auth_type
#   `auth_type` use in GTC.
# @param tls_config_name
#   Name for the `tls-config`. It normally should not be used.
# @param tls_private_key_password
#   Private key password.
# @param tls_private_key_file
#   File with the private key of the server.
# @param tls_certificate_file
#   File with the certificate of the server.
# @param tls_ca_file
#   File with the trusted root CA list.
# @param tls_auto_chain
#   When setting to `no`, the server certificate file MUST include the full certificate chain.
# @param tls_psk_identity
#   PSK identity (if OpenSSL supports TLS-PSK).
# @param tls_psk_hexphrase
#   PSK (hex) password (if OpenSSL supports TLS-PSK).
# @param tls_dh_file
#   DH file.
# @param tls_random_file
#   Random file.
# @param tls_fragment_size
#   Fragment size for TLS packets.
# @param tls_include_length
#   If set to no, total length of the message is included only in the first packet of a fragment series.
# @param tls_check_crl
#   Check the certificate revocation list.
# @param tls_check_all_crl
#   Check if intermediate CAs have been revoked.
# @param tls_allow_expired_crl
#   Allow use of an expired CRL.
# @param tls_ca_path
#   Path to the CA file.
# @param tls_check_cert_issuer
#   If set, the value will be checked against the DN of the issuer in the client certificate.
# @param tls_check_cert_cn
#   If it is set, the value will be xlat'ed and checked against the CN in the client certificate.
# @param tls_cipher_list
#   Set this option to specify the allowed TLS cipher suites.
# @param tls_disable_tlsv1_2
#   Disable TLS v1.2.
# @param tls_min_version
# @param tls_max_version
# @param tls_ecdh_curve
#   Elliptical cryptography configuration.
# @param tls_cache_enable
#   Enable TLS cache.
# @param tls_cache_lifetime
#   Lifetime of the cached entries, in hours.
# @param tls_cache_max_entries
#   The maximum number of entries in the cache.
# @param tls_cache_name
#   Internal name of the session cache.
# @param tls_cache_persist_dir
#   Simple directory-based storage of sessions.
# @param tls_verify_skip_if_ocsp_ok
#   If the OCSP checks suceed, the verify section is run to allow additional checks.
# @param tls_verify_tmpdir
#   Temporary directory where the client certificates are stored.
# @param tls_verify_client
#   The command used to verify the client certificate.
# @param tls_ocsp_enable
#   Enable OCSP certificate verification.
# @param tls_ocsp_override_cert_url
#   If set to `yes` the OCSP Responder URL is overrided.
# @param tls_ocsp_url
#   The URL used to verify the certificate when `tls_ocsp_override_cert_url` is set to `yes`.
# @param tls_ocsp_use_nonce
#   If the OCSP Responder can not cope with nonce in the request, then it can be set to `no`.
# @param tls_ocsp_timeout
#   Number of seconds before giving up waiting for OCSP response.
# @param tls_ocsp_softfail
#   To treat OCSP errors as _soft_.
# @param tls_virtual_server
#   Virtual server for EAP-TLS requests.
# @param ttls_default_eap_type
#   Default EAP type use inside the TTLS tunnel.
# @param ttls_copy_request_to_tunnel
#   If set to `yes`, any attribute in the ouside of the tunnel but not in the tunneled request is copied to the tunneled request.
# @param ttls_use_tunneled_reply
#   If set to `yes`, reply attributes get from the tunneled request are sent as part of the outside reply.
# @param ttls_virtual_server
#   The virtual server that will handle tunneled requests.
# @param ttls_include_length
#   If set to no, total length of the message is included only in the first packet of a fragment series.
# @param ttls_require_client_cert
#   Set to `yes` to require a client certificate.
# @param peap_default_eap_type
#   Default EAP type used in tunneled EAP session.
# @param peap_copy_request_to_tunnel
#   If set to `yes`, any attribute in the ouside of the tunnel but not in the tunneled request is copied to the tunneled request.
# @param peap_use_tunneled_reply
#   If set to `yes`, reply attributes get from the tunneled request are sent as part of the outside reply.
# @param peap_proxy_tunneled_request_as_eap
#   Set the parameter to `no` to proxy the tunneled EAP-MSCHAP-V2 as normal MSCHAPv2.
# @param peap_virtual_server
#   The virtual server that will handle tunneled requests.
# @param peap_soh
#   Enables support for MS-SoH.
# @param peap_soh_virtual_server
#   The virtual server that will handle tunneled requests.
# @param peap_require_client_cert
#   Set to `yes` to require a client certificate.
# @param mschapv2_send_error
#   If set to `yes`, then the error message will be sent back to the client.
# @param mschapv2_identity
#   Server indentifier to send back in the challenge.
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
