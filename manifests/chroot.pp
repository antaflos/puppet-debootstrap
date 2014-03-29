# vim: tabstop=2 shiftwidth=2 softtabstop=2

# Module: 'debootstrap'
# Author: Morphlabs - Aimon Bustardo <abustardo at morphlabs dot com>
# Descr:  Puppet Module for managing Chrooted apps via 'debootstrap'
# This defined type is a wrapper for the debootstrap type.

define debootstrap::chroot(
  $target,
  $mirror,
  $ensure      = 'present',
  $chroot      = $title,
  $description = $title,
  $suite       = 'precise',
  $arch        = 'amd64',
  $variant     = 'buildd',
  $users       = [],
  $groups      = [],
  $root_users  = [],
  $root_groups = [ 'root', 'admin' ],
  $includes    = [],
  $excludes    = [],
  $components  = [],
){

  include 'debootstrap::packages'

  # Directories
  exec { "create target dir for ${title}":
    command  => "/bin/mkdir -p ${target}",
    creates  => $target,
    provider => 'posix',
  }
  # debootstrap
  debootstrap { $chroot:
    ensure      =>  $ensure,
    target      =>  $target,
    suite       =>  $suite,
    arch        =>  $arch,
    variant     =>  $variant,
    includes    =>  $includes,
    excludes    =>  $excludes,
    components  =>  $components,
    mirror      =>  $mirror,
    require     =>  [
      Exec["create target dir for ${title}"],
      Class[debootstrap::packages]
    ],
  }

  # Schroot Confs
  file { "/etc/schroot/chroot.d/${chroot}.conf":
    ensure  =>  $ensure,
    mode    =>  '0660',
    owner   =>  'root',
    group   =>  'root',
    content =>  template('debootstrap/schroot.d.conf.erb'),
    require =>  Debootstrap[$chroot],
  }
}
