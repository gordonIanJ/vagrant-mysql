#!/usr/bin/env bash

LIB_DIR='/vagrant/provisioners/scripts/lib'
PATCHES_DIR='/vagrant/patches/server/TAR'
RUN_DIR='/home/vagrant/opt/mysql/run' 
STATE_DIR='/home/vagrant/opt/mysql/state'
SHELL_RUN_DIR='/home/vagrant/opt/mysql_shell'
TMP_DIR='/home/vagrant/tmp'

available_ports=()

#TODOwhich wget >/dev/null 2>&1 || echo 'Please ensure the wget command is available' && exit
#TODOwhich unzip >/dev/null 2>&1 || echo 'Please ensure the unzip command is available' && exit

[ ! -d $LIB_DIR ] && mkdir -p $LIB_DIR && echo "Please ensure the runsub file is copied into $LIB_DIR" && exit
[ ! -d $RUN_DIR ] && mkdir -p $RUN_DIR
[ ! -d $STATE_DIR ] && mkdir -p $STATE_DIR
[ ! -d $SHELL_RUN_DIR ] && mkdir -p $SHELL_RUN_DIR && echo "Please unzip a MySQL Shell patch into $SHELL_RUN_DIR" && exit

function sub_default () {
  echo "Usage: $progname <subcommand> [options]"
  echo "Subcommands:"
  echo "    TODO:name    TODO:description" # TODO
  echo "    TODO:name    TODO:description" # TODO
  echo 
  echo "For help with each subcommand run:"
  echo "$progname <subcommand> -h"
  echo
}
export -f sub_default

# Commands

sub_add () { 
  echo 'In sub_add!' 
  local before=''
  local after=''
  local patch=''
  local usage="Usage: $progname add [-b instance_name_prefix] [-a instance_name_postfix] -p patch"
  local OPTIND
  while getopts b:a:p:h opt
  do
    case $opt in
      b ) before=$OPTARG ;;
      a ) after=$OPTARG ;;
      p ) patch=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  echo "patch is: $patch" 
  [ -z "$patch" ] && echo $usage && exit 0 
  local name=''
  local patch=''
  ls $PATCHES_DIR
  for file in $(ls "$PATCHES_DIR")
  do
    if [[ $file == *"p$patch"* ]]
    then
      if [[ "$file" == *'.tar'* ]] || [[ "$file" == *'.gz'* ]] || [[ $file == *'.xz' ]]  
      then
        patch=$file
        break
      fi
    fi
  done
  echo "patch is: $patch" 
  [ -z "$patch" ] && echo "Please copy into "$PATCHES_DIR/" the package file with name that matches \"p$patch\" and ends in .tar or .gz or .xz" && exit 
  case $patch in
    *.gz) local pattern=.gz ;;
    *.xz) local pattern=.xz ;;
    *.tar) local pattern=.tar ;;
  esac
  local barename=$(echo "$patch" |sed "s/\.tar\\$pattern//")
  [ -z "$before" ] || name="$before-${barename}" 
  [ -z "$after" ] || name="${barename}-$after"
  [ -z "$name" ] && name=$barename 
  unpack $patch $name $barename
  initialize $name
  configure_minimally $name
}
export -f sub_add

sub_start () {
  local name=''
  local port_options=''
  local usage="Usage: $progname start [-g] -n name_of_instance"
  local OPTIND
  while getopts "n:h" opt; do
    case $opt in
      n ) name=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  options_file=$STATE_DIR/$name/my.cnf
  set_available_ports
  port_options="--port=${available_ports[0]}"
  echo $name 
  if [[ $name == *'-8.'* ]]; then port_options="$port_options --mysqlx_port=${available_ports[1]}"; fi
  $RUN_DIR/$name/bin/mysqld --defaults-file=$options_file $port_options &
  available_ports=''
}
export -f sub_start

sub_stop () {
  local name=''
  local OPTIND
  while getopts "n:h" opt; do
    case $opt in
      n ) name=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  if [ -f $STATE_DIR/$name/mysqld.pid ]
  then
    echo "Stopping $name... "
    kill $(cat $STATE_DIR/$name/mysqld.pid)
    while [ -f $STATE_DIR/$name/mysqld.pid ]
    do 
      echo -n 'x'
      sleep 1
    done
    echo && echo "Stopped $name"
  fi
}
export -f sub_stop

sub_restart () {
  local name=''
  local OPTIND
  while getopts "n:h" opt; do
    case $opt in
      n ) name=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  if [ -f $STATE_DIR/$name/mysqld.pid ]
  then
    echo "Stopping $name... "
    kill $(cat $STATE_DIR/$name/mysqld.pid)
    while [ -f $STATE_DIR/$name/mysqld.pid ]
    do 
      echo -n 'x'
      sleep 1
    done
    echo && echo "Stopped $name"
    sub_start -n $name
  else
    sub_start -n $name
  fi
}
export -f sub_restart

sub_clean () {
  local targets=()
  local usage="Usage: $progname clean [-d] [-c] -n name"
  local OPTIND
  while getopts dcln:h opt; do
    case $opt in
      d ) targets+=('data') ;;
      c ) targets+=('config') ;;
      l ) targets+=('log') ;;
      n ) local name=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac 
  done
  [ -z "$name" ] && echo $usage && exit 0 
  local data=$STATE_DIR/$name/data/*
  local config=$STATE_DIR/$name/my.cnf
  local error_log=$STATE_DIR/$name/error.log
  sub_stop -n $name
  [ "${#targets[@]}" -lt 1 ] && rm -rf $data $config && initialize $name && configure_minimally $name && exit 0
  for i in "${targets[@]}" 
  do
    [ "$i" == 'data' ] &&  rm -rf $data && initialize $name
    [ "$i" == 'config' ] &&  rm -rf $config  && configure_minimally $name
    [ "$i" == 'log' ] &&  rm -rf $error_log
  done
}
export -f sub_clean

sub_set_option() {
  local usage="Usage: $progname set_option -s section_of_config -o option_to_set -v value_to_assign"
  local OPTIND
  while getopts "s:o:v:h" opt; do
    case $opt in
      s ) section=$OPTARG ;;
      o ) option=$OPTARG ;;
      v ) value=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
}
export -f sub_set_option

sub_list() {
  local name=''
  local mode='added'
  local OPTIND
  while getopts "r" opt; do
    case $opt in
      r ) mode=running ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  echo
  [ $mode == 'added' ] && ls -l $RUN_DIR |grep -v "^total" |awk '{print $9}' 
  [ $mode == 'running' ] && ps aux |grep $USER |grep mysqld |grep -v mysqlx_port |grep -v grep \
  |perl -nle '/.*\/(.*mysql-?\w?-\d?.\d?.\d?.*)\/.*port=(\d+).?/; print "$1 port $2";'
  [ $mode == 'running' ] && echo && ps aux |grep $USER |grep mysqld |grep mysqlx_port |grep -v grep \
  |perl -nle '/.*\/(.*mysql-\w+-\d?.\d?.\d?.*)\/.*port=(\d+).*mysqlx_port=(\d+)/; print "$1 port $2 xport $3"'
  echo
}
export -f sub_list

sub_connect () { 
  local name=''
  local client='cli'
  local user='root'
  local port=''
  local OPTIND
  while getopts "n:xu:p:h" opt; do
    case $opt in
      n ) name=$OPTARG ;;
      x ) client=shell;;
      u ) user=$OPTARG ;;
      p ) port=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  [ -z $name ] && echo $usage && exit 
  [ $client == 'cli' ] && $RUN_DIR/$name/bin/mysql -p -u$user --port=$port --socket=$STATE_DIR/$name/mysqld.sock 
  [ $client == 'shell' ] && $SHELL_RUN_DIR/bin/mysqlsh $user@127.0.0.1:$port
}
export -f sub_connect 

sub_edit () {
  local name=''
  local editor='/usr/bin/vim'
  local OPTIND
  while getopts "n:e:h" opt; do
    case $opt in
      n ) name=$OPTARG ;;
      e ) editor=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  [ -z "$name" ] && echo $usage && exit
  [ -z "$editor" ] && echo $usage && exit
  $editor $STATE_DIR/$name/my.cnf
}
export -f sub_edit

sub_remove () { 
  local name=''
  local OPTIND
  while getopts "n:h" opt; do
    case $opt in
      n ) name=$OPTARG ;;
      h ) echo $usage && exit ;;
      \? ) echo $usage && exit ;;
    esac
  done
  sub_stop -n $name
  [ -d $STATE_DIR/$name ] && rm -rf $STATE_DIR/$name
  [ -d $RUN_DIR/$name ] && rm -rf $RUN_DIR/$name
}
export -f sub_remove

## Helpers

set_available_ports() {
  local unavailable_ports=($(ss -tan  \
  | awk '{ if ($4 ~ /[0-9]+/) {print $4} }' \
  | cut -d':' -f2))
  unavailable_ports+=($(cat /etc/services \
  |awk '{ if ($1 !~ /#/ && $1 ~ /[0-9]+/) {print $2} }' \
  |cut -d/ -f1))
  available_ports=($(comm -23 \
  <(seq 1025 32767 |sort) \
  <(echo ${unavailable_ports[*]} |sort -u) \
  | shuf |sed 's/^ *//;s/ *$//' |head -n 2))
}

fetch () {
  local url=$1 
  local patch=$(basename "$url")
  cd $PATCHES_DIR && { curl --fail -O $url; cd -; }
}

unpack () {
  local patch=$1
  local name=$2
  local barename=$3
  local destination=$RUN_DIR 
  case $patch in
    *.gz) local options=-zxvf ;;
    *.xz) local options=-xvf ;;
    *.tar) local options=-xvf ;;
  esac 
  echo "destination/name is: $destination/$name" 
  if [ ! -d "$destination/$name/bin" ]
  then
    mkdir -p $destination/$name && \
    # TODO: unzip the patch before untarring 
    cd $PATCHES_DIR && { unzip $patch; cd -; }
    unzip $PATCHES_DIR/$patch
    tar $options $PATCHES_DIR/$patch -C $destination/$name && \
    mv $destination/$name/$barename/* $destination/$name &&\
    rm -r $destination/$name/$barename
  fi
  #[ ! -d "$destination/$name/bin" ] && rm -rf $destination/$name && echo "The unpacking of $patch was not successful." && exit 
  [ ! -d "$destination/$name/bin" ] && echo "The unpacking of $patch was not successful." && exit 
}

initialize () {
  local name=$1
  datadir=$STATE_DIR/$name/data
  [ -d $datadir ] || mkdir -p $datadir && chmod 750 $datadir
  if [ ! -f "$RUN_DIR/$name/bin/mysqld" ]
  then
    echo "Something went wrong. There's no mysqld file for this patch." && exit
  fi 
  [ "$(ls -A $datadir)" ] || $RUN_DIR/$name/bin/mysqld --initialize-insecure --user=$(whoami) --datadir=$datadir --basedir=$RUN_DIR/$name
}

configure_minimally () {
  local name=$1
  options_file=$STATE_DIR/$name/my.cnf
  [ -f $options_file ] || cat << EOF > $options_file 
[mysqld]

basedir       = $RUN_DIR/$name
datadir       = $STATE_DIR/$name/data
pid-file      = $STATE_DIR/$name/mysqld.pid
socket        = $STATE_DIR/$name/mysqld.sock 
log-error     = $STATE_DIR/$name/error.log 
bind-address  = 127.0.0.1 
EOF
  if [[ $name == *'-8'* ]]; then echo mysqlx_socket = $STATE_DIR/$name/mysqlx.sock >> $options_file; fi
}

. $LIB_DIR/runsub $@
