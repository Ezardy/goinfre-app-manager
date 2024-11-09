#!/bin/sh

APP_PATH="$(dirname -- "${BASH_SOURCE[0]}")"
APP_PATH="$(cd -- "$APP_PATH" && pwd)"
if [[ -z "$APP_PATH" ]] ; then
  echo "app path calculation failed"
  exit 1
fi

export CONFIG_PATH=$APP_PATH/.goinfre_app_manager.conf
export SCRIPTS_PATH=$APP_PATH/Scripts
export RECORDS_PATH=$APP_PATH/.goinfre_apps

if [[ ! -f $CONFIG_PATH ]]; then
	echo \
'#!/bin/sh
GOINFRE_PATH=~/goinfre
DOWNLOADS_PATH=$GOINFRE_PATH/Downloads
APPLICATIONS_PATH=$GOINFRE_PATH/Applications' > $CONFIG_PATH
fi

set -a
source $CONFIG_PATH
set +a
mkdir -p $DOWNLOADS_PATH $APPLICATONS_PATH $SCRIPTS_PATH

if [[ ! -f $RECORDS_PATH ]]; then
	touch $RECORDS_PATH
fi

list()
{
	cat -n $RECORDS_PATH
}

find()
{
	if [[ -z $1 ]]; then
		list
	else
		list | grep $1
}

restore()
{
	if [[ $1=="force" ]]; then
		local app_str=echo $* | awk '{for (i=2; i<=NF; i += 1) print $i}'
		local suffix=$1
	else
		local app_str=$*
		local suffix=
	fi
	if [[ -z $app_str ]]; then
		app_str=awk '{print $1}' 
	for app in $app_str; do
		restore_single $app $suffix
}

restore_single()
{
	awk -v name=$1 \
		'name==$1 {if (NF > 2) exit 0; else exit 2;}
		END {exit 1}'
	if [[ $? == 0 ]]; then
		local path=$APPLICATIONS_PATH/$1
		local should_restore=[[ $2=="force" || ! -d $path ]]
		if $should_restore; then
			$(awk -v name=$1 -v dst_path=$DOWNLOADS_PATH/$(openssl rand -base64 12 | tr -dc A-Za-z0-9)\
				'name==$1
				{
					command="echo "name" "$2" "dst_path;
					for (i=3; i<=NF; i += 1)
						command=command" | "$i
				}
				END {print command}')
		else
			echo "$1 already installed. If you want to reinstall it use 'restore force app_name' command"
		fi
	elif [[ $? == 1 ]]
		echo "$1: no such app"
	else
		echo "$1: app entry should contain at least one installation script. Consider to remove this entry"
	fi
}

add()
{
	if (( $# < 3 )); then
		echo "Usage: add app_name app_url script_name_1 ... script_name_n"
	else
		$* >> $RECORDS_PATH
		restore_single $1
}

remove()
{
	local app=$(get_name $1)
}

get_name()
{
	if [[ $1 =~ '^0$|^[1-9][0-9]*$' ]]; then
		local app=awk "NR==$1" $RECORDS_PATH
	else
		local app=$1
	fi
	return app
}
