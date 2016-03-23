#!/bin/sh

GIT_PROJECT_NAME="YYKuaibo"

RESPO_URL="git@git.coding.net:seanyue/$GIT_PROJECT_NAME.git"

STORAGE_DIR="$GIT_PROJECT_NAME"

GIT_EXEC="/usr/bin/git"

CURRENT_USER_HOME=`cd ~;pwd`
LOCAL_PROJECT_DIR="$CURRENT_USER_HOME/$STORAGE_DIR"
THREAD_NUM=4
cd ~

if [ -z "$GIT_PROJECT_NAME" ]; then 
	echo "git project directory is empty"
	exit 1
fi
if [ -d "$LOCAL_PROJECT_DIR" ]; then 
	rm -rf $LOCAL_PROJECT_DIR >/dev/null 2>&1
	if [ $? != 0 ]; then
       		echo "deleting $LOCAL_PROJECT_DIR directory failed"
        	exit 1
	fi
fi

eval "$GIT_EXEC clone $RESPO_URL $LOCAL_PROJECT_DIR --branch standby > /dev/null 2>&1"

if [ $? != 0 ]; then
	echo "$LOCAL_PROJECT_DIR can not be download"
        exit 1
fi

for i in `eval echo {1..$THREAD_NUM}`; do
	if [ -d "$LOCAL_PROJECT_DIR$i" ]; then
		rm -rf $LOCAL_PROJECT_DIR$i >/dev/null 2>&1
		if [ $? != 0 ]; then
                	echo "deleting $LOCAL_PROJECT_DIR$i backup directory failed"
                	exit 1
        	fi
	fi
	cp -rf $LOCAL_PROJECT_DIR $LOCAL_PROJECT_DIR$i >/dev/null 2>&1
done
