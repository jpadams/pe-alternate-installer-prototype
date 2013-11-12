class pe_role::database (
  $listen_addresses = '*',
) {

  class { 'pe_postgresql::server':
    listen_addresses        => $listen_addresses,
    ip_mask_allow_all_users => '0.0.0.0/0',
  }

}
