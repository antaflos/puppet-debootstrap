# vim: tabstop=2 shiftwidth=2 softtabstop=2

# Module: 'debootstrap'
# Author: Morphlabs - Aimon Bustardo <abustardo at morphlabs dot com>
# Descr:  Puppet Module for managing Chrooted apps via 'debootstrap'
# This defined type is a wrapper for the debootstrap type.

define debootstrap::chroot(
  $vensure,
  $vtarget,
  $vusers,
  $mirror,
  $vname=$title,
  $suite='precise',
  $arch='amd64',
  $variant='buildd',
  $includes=False,
  $exclude=False,
  $components=False,
){

  include 'debootstrap::packages'

  # Directories
  exec{ "create vtarget for ${title}":
    command  => "/bin/mkdir -p ${vtarget}",
    creates  => $vtarget,
    provider => 'posix',
  }
  # debootstrap
  debootstrap{$vname:
    ensure      =>  $vensure,
    target      =>  $vtarget,
    suite       =>  $suite,
    arch        =>  $arch,
    variant     =>  $variant,
    includes    =>  $includes,
    exclude     =>  $exclude,
    components  =>  $components,
    mirror      =>  $mirror,
    require     =>  [Exec["create vtarget for ${title}"], Class[debootstrap::packages]],
  }
  # Schroot Confs
  file{"/etc/schroot/chroot.d/${vname}.conf":
    ensure  =>  $vensure,
    mode    =>  '0660',
    owner   =>  'root',
    group   =>  'root',
    content =>  template('debootstrap/schroot.d.conf.erb'),
    require =>  Debootstrap[$vname],
  }
}
