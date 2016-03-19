# Class: win_iis
#
# This module manages MS Internet Information Services(IIS) and depends on forge's puppet-iis module
#
class win_iis {
  $site_folders_to_ensure = ["C:\\inetpub\\",
  			     "C:\\inetpub\\wwwroot", 
  			     "C:\\inetpub\\wwwroot\\mywebsite"]

  File {
    mode   => '755',
    ensure => 'directory',
  }

  file { $site_folders_to_ensure: } ->
  windowsfeature { 'Web-Server':
    ensure                 => 'present',
    installsubfeatures     => true,
    installmanagementtools => true,
    restart                => false,
  } ->
  windowsfeature { 'Web-Scripting-Tools':
    ensure                 => 'present',
    installsubfeatures     => true,
    installmanagementtools => true,
    restart                => false,
  } ->
  ::iis::manage_app_pool { 'my_application_pool':
    enable_32_bit                => true,
    managed_runtime_version      => 'v4.0',
    apppool_idle_timeout_minutes => 60, # 30 days (43200 min) is max value for this in iis, 0 disables
  } ->
  ::iis::manage_site { 'www.mywebsite.com':
    ssl         => false,
    site_path   => 'C:\inetpub\wwwroot\mywebsite',
    port        => '80',
    ip_address  => '*',
    host_header => 'mywebsite.com',
    app_pool    => 'my_application_pool'
  } ->
  # Below code for sake of website hosting and showing index.html at http://localhost/mywebsite
  # updating basic acl settings
  file { "C:\\inetpub\\wwwroot\\mywebsite\\index.html":
    source => "puppet:///modules/${module_name}/index.html",
    ensure => file,
    mode   => '644'
  }

  # puppet-iis module do not ensure if the iis service is running
  service { 'W3SVC':
    ensure => 'running',
    enable => true,
  }

}
