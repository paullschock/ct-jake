# Class: digistorm-web
#
# This module manages digistorm amazon linux install
#
# Parameters: none
#
# Actions: Bootstrapping needs to happen
#
#
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
# yum -y install puppet
# puppet module install jfryman-nginx
#
# Requires: see Modulefile
#
# Sample Usage:
#
# puppet apply --modulepath /etc/puppet/modules/ /etc/puppet/manifests/digistorm-web.pp


class digistorm-web {

  # Workapp specific variables
  $domain = 'digistorm.local'
  $www_root = '/var/www'
  $fastcgi_backend = '127.0.0.1:9000'
  $memory_limit = '128M'
  $upload_max_filesize = '10M'
  $post_max_size ='10M'

  #this is a failsafe
  $memcache_endpoint = 'localhost:11211'

  #fpm specific
  $pm = 'dynamic'
  $max_children = 50
  $start_servers = 5
  $min_spare_servers = 5
  $max_spare_servers = 35
  $max_requests = 0
  $fpm_user = 'nginx'
  $fpm_group = 'nginx'


  #nginx installer and configuration
  class{ 'nginx':
    manage_repo    => true,
    package_source => 'nginx-stable'
  }

  nginx::resource::vhost { "${domain}":
    ensure              => present,
    listen_port           => 80,
    www_root              => $www_root,
    index_files           => [ 'index.php', 'index.html', 'index.htm' ],
    ssl                   => false,

  }

  nginx::resource::location { "${domain}_static":
    ensure          => present,
    vhost           => "${domain}",
    www_root        => $www_root,
    location        => '~* ^.+.(jpg|jpeg|gif|css|png|js|ico|xml)$',
    location_cfg_append => {
      expires         => '15d',
    },
    proxy           => undef,
    fastcgi_script  => undef,
  }

  nginx::resource::location { "${domain}_root":
    ensure          => present,
    vhost           => "${domain}",
    www_root        => "${www_root}",
    location        => '~ \.php$',
    index_files     => ['index.php', 'index.html', 'index.htm'],
    proxy           => undef,
    fastcgi         => "${fastcgi_backend}",
    fastcgi_script  => undef,
    fastcgi_param  => {
      'REQUEST_URI'  =>  '$request_uri',
      'QUERY_STRING' => '$query_string',
      'REQUEST_METHOD'  =>  '$request_method',
      'CONTENT_TYPE'  =>  '$content_type',
      'CONTENT_LENGTH' => '$content_length',
    },

  }

  #git would be handy
  package {'git':
    ensure => installed,
  }

  #php dependencies
  package {'php56w-common':
    ensure => installed,
  }

  package {'php56w-mcrypt':
    ensure => installed,
  }

  package {'php56w-opcache':
    ensure => installed,
  }

  package {'php56w-pdo':
    ensure => installed,
  }

  package {'php56w-mssql':
    ensure => installed,
  }

  package {'php56w-ldap':
    ensure => installed,
  }

  package {'php56w-gd':
    ensure => installed,
  }

  package {'php56w-fpm':
    ensure => installed,
  }
  package {'php56w-pecl-memcache':
    ensure => installed,
  }

  package {'php56w-pecl-memcached':
    ensure => installed,
  }

  package {'php56w-pecl-geoip':
    ensure => installed,
  }

  package {'php56w-pecl-imagick':
    ensure => installed,
  }

  # memcached for local failover
  package {'memcached':
    ensure => installed,
  }

  service { 'memcached':
    provider => systemd,
    ensure => running,
    enable => true,
    require => Package['memcached'],
  }

  #nginx running
  service { 'nginx.service':
    provider => systemd,
    ensure => running,
    enable => true,
    require => Class['nginx'],
  }

  #php configuration
  service { 'php-fpm.service':
    provider => systemd,
    ensure => running,
    enable => true,
    require => Package['php56w-fpm'],
    notify => Package['codedeploy-agent'],
  }
  group { 'web':
    ensure => 'present',
  }

  file { '/etc/php.ini':
    ensure => 'file',
    owner => 'root',
    group => 'root',
    content => template('/etc/puppet/templates/php.ini.erb'),
    notify => Service['php-fpm.service'],
    require => Package['php56w-fpm'],
  }
  #fpm config
  file { '/etc/php-fpm.d/www.conf':
    ensure => 'file',
    owner => 'root',
    group => 'root',
    content => template('/etc/puppet/templates/www.conf.erb'),
    notify => Service['php-fpm.service'],
    require => Package['php56w-fpm'],
  }


  #code deploy
  package { 'codedeploy-agent':
    provider => 'rpm',
    ensure => installed,
    source => 'https://s3-ap-southeast-2.amazonaws.com/aws-codedeploy-ap-southeast-2/latest/codedeploy-agent.noarch.rpm',
    require => Service['php-fpm.service'],
  }

}

include digistorm-web