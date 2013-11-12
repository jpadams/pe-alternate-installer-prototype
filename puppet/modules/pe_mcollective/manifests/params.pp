class pe_mcollective::params (
  $set_stomp_servers = $::fact_stomp_servers,
) {
  # API WARNING: PE docs rely on the $mco_etc, $root_owner, $root_group,
  # $root_mode variables. See:
  # http://docs.puppetlabs.com/pe/latest/orchestration_adding_actions.html
  if $::osfamily == 'windows' {
    $mco_etc    = "${common_appdata}/PuppetLabs/mcollective/etc"
    $facter_etc = "${common_appdata}/PuppetLabs/facter/etc"
    $root_owner = 'S-1-5-32-544' # Adminstrators
    $root_group = 'S-1-5-18'     # SYSTEM
    $root_mode  = '0664'         # Both user and group need write permission
  } else {
    $mco_etc    = '/etc/puppetlabs/mcollective'
    $facter_etc = '/etc/puppetlabs/facter'
    $root_owner = 0
    $root_group = 0
    $root_mode  = '0644'
  }

  # Warning printed on non-pe 3 agents when pe_mcollective classification is
  # issued to them
  $warn_nonpe3_agent = join([
    "In order for the Puppet Enterprise 3 master to communicate with an agent",
    "using MCollective, the agent must also be version 3. \n The ${::clientcert}",
    "node is running Puppet Enterprise version ${::pe_version} so it cannot",
    "communicate with the PE 3 master either via the Console's Live Management",
    "view or via the MCO command line tool. \n To fix this, upgrade the agent to",
    "Puppet Enterprise 3. \n To disable this message in the future,",
    "use the Puppet Enterprise console to create the parameter key",
    "`warn_on_nonpe3_agents` in the pe_mcollective class, and set its value to",
    "false",
  ], ' ')

  # Warning printed on non-pe agents when pe_mcollective classification is
  # issued to them
  $warn_nonpe_agent = join([
    "${::clientcert} (osfamily = ${::osfamily}) is not a Puppet Enterprise",
    "agent. It will not appear when using the mco command-line tool or from",
    "within Live Management in the Puppet Enterprise Console. \n You may",
    "voice your opinion on PE platform support here:",
    "http://links.puppetlabs.com/puppet_enterprise_3.x_platform_support \n If",
    "you no longer wish to see this message for all non-PE agents, visit your",
    "Puppet Enterprise Console, create the parameter warn_on_nonpe_agents in",
    "the pe_mcollective class, and set its value to false",
  ], ' ')

  $fail_nonpe_agent = join([
    "${::clientcert} (osfamily = ${::osfamily}) is not a Puppet Enterprise",
    "agent. Non-PE nodes may not be classified with pe_mcollective roles. \n",
    "You may voice your opinion on PE platform support here:",
    "http://links.puppetlabs.com/puppet_enterprise_3.x_platform_support",
  ], ' ')

  # #10961 This variable is used by the activemq-wrapper.conf template to set
  # the initial and maximum java heap size.  The value is looked up in the
  # class parameter, then the global scope so it may be set as a Fact or Node
  # Parameter.
  $activemq_heap_mb = $::activemq_heap_mb ? {
    undef   => '512',
    default => $::activemq_heap_mb,
  }

  # PE-1611 This variable is used by the activemq.xml template to set the
  # number of brokers in the network that messages and subscriptions can pass
  # through. Default of '2' works for spoke-and-hub configurations.
  $activemq_network_ttl = pick($::activemq_network_ttl, '2')

  #Allow overwriting from the console
  $mcollective_registerinterval = $::mcollective_registerinterval ? {
    undef   => '600',
    default => $::mcollective_registerinterval,
  }

  # #12210 Sets up openwire connectors for replicating messages across all
  # brokers.  The class parameter takes precedence over the topscope variable.
  $activemq_brokers = split($::activemq_brokers, ',')

  # Stomp SSL Support
  # Turned on by default.
  $mcollective_enable_stomp_ssl = $::mcollective_enable_stomp_ssl ? {
    'true'  => true,
    'false' => false,
    undef   => true,
    ''      => true,
    default => $::mcollective_enable_stomp_ssl,
  }

  $stomp_servers = $set_stomp_servers ? {
    undef   => [$settings::server],
    default => split($set_stomp_servers,','),
  }
  $stomp_port = $::fact_stomp_port ? {
    undef   => '61613',
    default => $::fact_stomp_port,
  }

  # This will only fail validation if the user is using external facts and has a bogus port set.
  validate_re($stomp_port, '^[0-9]+$', join([
    "The fact named fact_stomp_port is not numeric. It is currently set to:",
    "[${::fact_stomp_port}]. A common cause of this problem is running",
    "puppet agent as a normal user instead of root or the facts missing from",
    "${facter_etc}/facts.d/puppet_installer.txt."
  ], ' '))

  # This will only fail validation if the user is using external facts and has a bogus servername set.
  validate_re($stomp_servers[0], '^[a-zA-Z0-9.-]+(,[a-zA-Z0-9.-]+)*$', join([
    "The fact named fact_stomp_server does not appear to be a valid hostname.",
    "The value of '${::fact_stomp_server}' does not match '^[a-zA-Z0-9.-]+$'.",
    "A common cause of this problem is running puppet agent as a normal user",
    "instead of root, or the fact is missing from",
    "${facter_etc}/facts.d/puppet_installer.txt."
  ], ' '))

  # Variables used by ERB templates.  This may be dynamically generated in the future.
  $stomp_user     = 'mcollective'
  # Editors leave trailing newlines.
  if $::stomp_password {
    $stomp_password = $::stomp_password
  } else {
    $existing_credentials = chomp(file('/etc/puppetlabs/mcollective/credentials', '/dev/null'))
    $generate_shell_command = join([
      'dd if=/dev/urandom count=20 2> /dev/null', '|',
      'LC_ALL=C tr -cd "[:alnum:]"', '|',
      'head -c 20 2>/dev/null'
    ], ' ')
    $stomp_password = $existing_credentials ? {
      undef   => generate('/bin/sh', '-c', $generate_shell_command),
      default => $existing_credentials,
    }
  }

  # $::is_pe is a custom fact shipped with the stdlib module
  $is_pe = str2bool($::is_pe)
}
