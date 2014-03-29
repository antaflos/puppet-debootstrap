# vim: tabstop=2 shiftwidth=2 softtabstop=2

# Module: 'debootstrap'
# Author: Morphlabs - Aimon Bustardo <abustardo at morphlabs dot com>
# Descr:  Puppet Module for managing Chrooted apps via 'debootstrap'
# This defined type is a wrapper for the debootstrap type.

# === Define debootstrap::chroot
#
# This type is a wrapper around the debootstrap type. It also creates a schroot configuration file.
#
# ====  Parameters
#
# [*target*]
#  The fully qualified target directory in which this chroot will be created. This argument is mandatory. (e.g.: /var/chroot/${title})
#
# [*mirror*]
#  Debian or Ubuntu mirror to use. This argument is mandatory.
#
# [*ensure*]
#  Ensure this chroot is 'present' or 'absent'. (Default: present)
#
# [*chroot*]
#  Name of this chroot. (Default: same as $title)
#
# [*description*]
#  Optional description of this chroot. (Default: same as $title)
#
# [*suite*]
#  The Distribution Suite which to install. e.g.: wheezy, hardy.. (Default: precise)
#
# [*arch*]
#  The architecture of this chroot's OS. i386 or amd64 (Default: amd64)
#
# [*variant*]
#  The variant of this chroot's deboostrap install. Can be buildd, fakechroot, minbase, scratchbox. (Default: buildd)
#
# [*users*]
#  The users which shall be granted access to this chroot (per schroot.conf). (Default: [])
#
# [*groups*]
#  The groups which shall be granted access to this chroot (per schroot.conf). (Default: [])
#
# [*root_users*]
#  The users which shall be granted passwordless root access to this chroot (per schroot.conf). (Default: [])
#
# [*root_grouops*]
#  The groups which shall be granted passwordless root access to this chroot (per schroot.conf). (Default: [ root, admin])
#
# [*includes*]
#  Adds specified names to the list of base packages. (Default: [])
#
# [*excludes*]
#  Removes specified names to the list of base packages. (Default: [])
#
# [*components*]
#  Use packages from the listed components of the archive. (Default: [])
#
# === Examples
#
# debootstrap::chroot { "ops-wheezy-packages":
#   ensure     => "present",
#   target     => "/var/chroot/ops-wheezy-packages",
#   suite      => "wheezy",
#   mirror     => "http://ftp.ch.debian.org/debian/"
#   includes   => ["sudo", "zsh"],
#   user       => [ "jenkins", "joan" ],
#   root_users => [ "joan", "karl" ],
# }
#

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
