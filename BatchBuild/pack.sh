#!/bin/sh

PRG="$0"

PROJECT_NAME="YYKuaibo"
SCHEME="$PROJECT_NAME"

CURRENT_USER_HOME=`cd ~;pwd`
PROJECT_DIR="$CURRENT_USER_HOME/$PROJECT_NAME"
IPA_DES_DIR="$CURRENT_USER_HOME/${PROJECT_NAME}IpaDir"
CHANNELNO_PRFIX="QB_VIDEO_IOS_B_"
CHANNELNO=
PRGDIR=`dirname $PRG`
PRGABSOLUTEDIR=`cd $PRGDIR;pwd`
IPA_EXEC="$PRGABSOLUTEDIR/ipa.sh"

MINPACKAGENO=$1
MAXPACKAGENO=$2

if [ ! -d "$IPA_DES_DIR" ]; then
	mkdir -p $IPA_DES_DIR 
fi

THREAD_NUM=4

mkfifo packpipe
exec 9<>packpipe

rm packpipe

for i in `eval echo {1..$THREAD_NUM}`; do
	echo "$i" 1>&9
done

cd ~

while [ $MINPACKAGENO -le $MAXPACKAGENO ]; do
	read -u 9 seq
	{
		MINPACKAGENOPADDING="`printf "%3d" $MINPACKAGENO | tr " " 0`"
		if [ -d "$IPA_DES_DIR/$MINPACKAGENOPADDING" ]; then 
			rm -rf $IPA_DES_DIR/$MINPACKAGENOPADDING > /dev/null 2>&1 
		fi
		mkdir -p $IPA_DES_DIR/$MINPACKAGENOPADDING
		CHANNELNO="$CHANNELNO_PRFIX`printf "%8d" $MINPACKAGENO | tr " " 0`"
		eval "$IPA_EXEC $PROJECT_DIR$seq $CHANNELNO $MINPACKAGENO $IPA_DES_DIR/$MINPACKAGENOPADDING $SCHEME"
		echo "$seq" 1>&9
	}&
	let MINPACKAGENO=MINPACKAGENO+1
done

wait

echo "successfully package"

exec 9>&-
