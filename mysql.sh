#!/bin/sh

#Tạo repo cho MariaDB 
cat > "/etc/yum.repos.d/Mariadb.repo" <<END
# MariaDB 10.1 CentOS repository list - created 2015-12-06 14:53 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
END

#Cài đặt MariDB
sudo yum install -y MariaDB-server MariaDB-client
sudo systemctl start mariadb
sudo systemctl enable mariadb

#Thiết lập  và cấu hình CSDL tự động
config=".my.cnf.$$"
command=".mysql.$$"

trap "interrupt" 1 2 3 6 15

rootpass=""
echo_n=
echo_c=
basedir=
defaults_file=
defaults_extra_file=
no_defaults=

parse_arg()
{
  echo "$1" | sed -e 's/^[^=]*=//'
}

parse_arguments()
{
  pick_args=
  if test "$1" = PICK-ARGS-FROM-ARGV
  then
    pick_args=1
    shift
  fi

  for arg
  do
    case "$arg" in
      --basedir=*) basedir=`parse_arg "$arg"` ;;
      --defaults-file=*) defaults_file="$arg" ;;
      --defaults-extra-file=*) defaults_extra_file="$arg" ;;
      --no-defaults) no_defaults="$arg" ;;
      *)
        if test -n "$pick_args"
        then
          args="$args $arg"
        fi
        ;;
    esac
  done
}

find_in_basedir()
{
  return_dir=0
  found=0
  case "$1" in
    --dir)
      return_dir=1; shift
      ;;
  esac

  file=$1; shift

  for dir in "$@"
  do
    if test -f "$basedir/$dir/$file"
    then
      found=1
      if test $return_dir -eq 1
      then
        echo "$basedir/$dir"
      else
        echo "$basedir/$dir/$file"
      fi
      break
    fi
  done

  if test $found -eq 0
  then
      $file --no-defaults --version > /dev/null 2>&1
      status=$?
      if test $status -eq 0
      then
        echo $file
      fi
  fi
}

cannot_find_file()
{
  echo
  echo "FATAL ERROR: Could not find $1"

  shift
  if test $# -ne 0
  then
    echo
    echo "The following directories were searched:"
    echo
    for dir in "$@"
    do
      echo "    $dir"
    done
  fi

  echo
  echo "If you compiled from source, you need to run 'make install' to"
  echo "copy the software into the correct location ready for operation."
  echo
  echo "If you are using a binary release, you must either be at the top"
  echo "level of the extracted archive, or pass the --basedir option"
  echo "pointing to that location."
  echo
}

parse_arguments PICK-ARGS-FROM-ARGV "$@"

if test -n "$basedir"
then
  print_defaults=`find_in_basedir my_print_defaults bin extra`
  echo "print: $print_defaults"
  if test -z "$print_defaults"
  then
    cannot_find_file my_print_defaults $basedir/bin $basedir/extra
    exit 1
  fi
  mysql_command=`find_in_basedir mysql bin`
  if test -z "$mysql_command"
  then
    cannot_find_file mysql $basedir/bin
    exit 1
  fi
else
  print_defaults="/usr/bin/my_print_defaults"
  mysql_command="/usr/bin/mysql"
fi

if test ! -x "$print_defaults"
then
  cannot_find_file "$print_defaults"
  exit 1
fi

if test ! -x "$mysql_command"
then
  cannot_find_file "$mysql_command"
  exit 1
fi

parse_arguments `$print_defaults $defaults_file $defaults_extra_file $no_defaults client client-server client-mariadb`
parse_arguments PICK-ARGS-FROM-ARGV "$@"

set_echo_compat() {
    case `echo "testing\c"`,`echo -n testing` in
	*c*,-n*) echo_n=   echo_c=     ;;
	*c*,*)   echo_n=-n echo_c=     ;;
	*)       echo_n=   echo_c='\c' ;;
    esac
}

prepare() {
    touch $config $command
    chmod 600 $config $command
}

do_query() {
    echo "$1" >$command
    #sed 's,^,> ,' < $command  # Debugging
    $mysql_command --defaults-file=$config $defaults_extra_file $no_defaults $args <$command
    return $?
}


basic_single_escape () {
    echo "$1" | sed 's/\(['"'"'\]\)/\\\1/g'
}

make_config() {
    echo "# mysql_secure_installation config file" >$config
    echo "[mysql]" >>$config
    echo "user=root" >>$config
    esc_pass=`basic_single_escape "$rootpass"`
    echo "password='$esc_pass'" >>$config
    #sed 's,^,> ,' < $config  # Debugging

    if test -n "$defaults_file"
    then
        dfile=`parse_arg "$defaults_file"`
        cat "$dfile" >>$config
    fi
}

set_root_password() {
    
	rootpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 16);
	
    esc_pass=`basic_single_escape "$rootpass"`
    do_query "UPDATE mysql.user SET Password=PASSWORD('$esc_pass') WHERE User='root';"
    if [ $? -eq 0 ]; then
	echo "Password updated successfully! $rootpass"
	echo "Reloading privilege tables.."
	reload_privilege_tables
	if [ $? -eq 1 ]; then
		clean_and_exit
	fi
	echo
	make_config
    else
	echo "Password update failed!"
	clean_and_exit
    fi

    return 0
}

remove_anonymous_users() {
    do_query "DELETE FROM mysql.user WHERE User='';"
    if [ $? -eq 0 ]; then
	echo " ... Success!"
    else
	echo " ... Failed!"
	clean_and_exit
    fi

    return 0
}

remove_remote_root() {
    do_query "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    if [ $? -eq 0 ]; then
	echo " ... Success!"
    else
	echo " ... Failed!"
    fi
}

remove_test_database() {
    echo " - Dropping test database..."
    do_query "DROP DATABASE test;"
    if [ $? -eq 0 ]; then
	echo " ... Success!"
    else
	echo " ... Failed!  Not critical, keep moving..."
    fi

    echo " - Removing privileges on test database..."
    do_query "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
    if [ $? -eq 0 ]; then
	echo " ... Success!"
    else
	echo " ... Failed!  Not critical, keep moving..."
    fi

    return 0
}

reload_privilege_tables() {
    do_query "FLUSH PRIVILEGES;"
    if [ $? -eq 0 ]; then
	echo " ... Success!"
	return 0
    else
	echo " ... Failed!"
	return 1
    fi
}

interrupt() {
    echo
    echo "Aborting!"
    echo
    cleanup
    stty echo
    exit 1
}

cleanup() {
    echo "Cleaning up..."
    rm -f $config $command
}

# Remove the files before exiting.
clean_and_exit() {
	cleanup
	exit 1
}

# The actual script starts here

prepare
set_echo_compat
rootpass=""
make_config

set_root_password
remove_anonymous_users

remove_remote_root
remove_test_database
reload_privilege_tables

echo "Password mysql root $rootpass"
echo "dbuname: nukeviet4, dbuname: nukeviet4 dbpass: $dbpass"

dbpass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 16);
dbuname="nukeviet4"
dbname="nukeviet4"

mysql -u root -p"$rootpass" -e "CREATE USER '$dbuname'@'localhost' IDENTIFIED BY '$dbpass';";
mysql -u root -p"$rootpass" -e "GRANT USAGE ON * . * TO '$dbuname'@'localhost' IDENTIFIED BY '$dbpass' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;";
mysql -u root -p"$rootpass" -e "CREATE DATABASE $dbname;";
mysql -u root -p"$rootpass" -e "GRANT SELECT , INSERT , UPDATE , DELETE , CREATE , DROP , INDEX , ALTER , CREATE TEMPORARY TABLES , CREATE VIEW , SHOW VIEW , CREATE ROUTINE, ALTER ROUTINE, EXECUTE ON $dbname . * TO '$dbuname'@'localhost'";

if [ -d "/home/nginx/nukeviet4/public_html/install/" ]; then
nv_password1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 7);
nv_password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 7);

cat > "/home/nginx/nukeviet4/public_html/install/default.php" <<END
 <?php

if( ! defined( 'NV_MAINFILE' ) ) die();

\$db_config['dbhost'] = 'localhost';
\$db_config['dbtype'] = 'mysql';
\$db_config['dbport'] = '';
\$db_config['dbname'] = '$dbname';
\$db_config['dbuname'] = '$dbname';
\$db_config['dbpass'] = '$dbpass';
\$db_config['dbdetete'] = 1;
\$db_config['prefix'] = 'nv4';

\$array_data['lang_multi'] = 0;
\$array_data['site_name'] = 'NukeViet CMS';
\$array_data['nv_login'] = 'admin';
\$array_data['nv_email'] = 'admin@nukeviet.vn';
\$array_data['nv_password'] = '$nv_password1@$nv_password2';
\$array_data['re_password'] = '$nv_password1@$nv_password2';
\$array_data['question'] = 'NukeViet CMS';
\$array_data['answer_question'] = 'NukeViet CMS 4';
\$array_data['socialbutton'] = 0;

END
chown nginx:nginx /home/nginx/nukeviet4/public_html/install/default.php
echo "Password website admin / $nv_password1@$nv_password2 when setup website"
fi