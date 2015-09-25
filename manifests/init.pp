#Class to manage beanstalkd on Redhat/Centos
class beanstalkd (
  $manage_package                 = true,
  $manage_sysconfig               = true,
  $package_name                   = 'beanstalkd',
  $package_ensure                 = 'present',
  $service_name                   = 'beanstalkd',
  $service_enable                 = true,
  $service_mod_init               = false,
  $beanstalkd_addr                = '0.0.0.0',
  $beanstalkd_port                = '11300',
  $beanstalkd_user                = 'beanstalkd',
  $beanstalkd_max_job_size        = '120000000',
  $beanstalkd_binlog_dir          = '/data/beanstalkd/',
  $beanstalkd_binlog_fsync_period = '300000',
  $beanstalkd_binlog_size         = '128000000',
) {
  validate_bool($manage_package)
  validate_string($package_name)
  validate_string($package_ensure)
  validate_string($service_name)
  validate_bool($service_enable)

  $beanstalkd_cfg = '/etc/sysconfig/beanstalkd'

  if $manage_package {
    package { $package_name:
      ensure => $package_ensure,
      before => [Service[$service_name], File[$beanstalkd_cfg]],
    }
  }

  if $package_ensure != 'absent' {
    if $service_enable {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }

    if $manage_sysconfig {
      file { $beanstalkd_cfg:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template("${module_name}/beanstalkd.erb"),
        notify  => Service[$service_name],
      }
    }

    if $service_mod_init {
      file { '/etc/init.d/beanstalkd':
        owner  => 'root',
        group  => 'root',
        source => "puppet:///modules/${module_name}/beanstalkd",
        mode   => '0755',
        before => Service[$service_name],
        notify => Service[$service_name],
      }
    }

    service { $service_name:
      ensure => $service_ensure,
      enable => $service_enable
    }
  }
}
