#!/bin/sh

#MODPLIST_EXEC="/usr/bin/modplist"
MODPLIST_EXEC="./BatchBuild/modplist"
XCODEBUILD_EXEC="/usr/bin/xcodebuild"
XCRUN_EXEC="/usr/bin/xcrun"

WORK_DIR="$1"
CHANNELNO="$2"
PACKAGENO=$3
IPA_DES_DIR="$4"

CURRENT_USER_HOME=`cd ~;pwd`
DERIVEDDATAPATH_DIR="$WORK_DIR"
SCHEME="$5"


NEXT_MODPLIST=
NEXT_XCBUILD=
NEXT_XCRUN=

if [ -z "$WORK_DIR" ]; then
        echo "work directory is empty"
        exit 1
fi

if [ -z "$CHANNELNO" ]; then 
	echo "channelno is empty"
	exit 1
fi

if [ -z "$PACKAGENO" ]; then
	echo "packageno is empty"
	exit 1
fi

if [ -d "$WORK_DIR" ]; then 
	NEXT_MODPLIST=1
else
	echo "work dir is not a directory"
        exit 1
fi
cd $WORK_DIR

if [ $NEXT_MODPLIST == 1 ]; then
	eval "$MODPLIST_EXEC $SCHEME/config.plist ChannelNo $CHANNELNO >> /Users/seanyue/BatchBuild.log"
	if [ $? != 0 ]; then
                echo "modplist faild"
                exit 1
        else
                NEXT_XCBUILD=1
        fi
fi


if [ $NEXT_XCBUILD == 1 ]; then
        eval "$XCODEBUILD_EXEC -workspace $SCHEME.xcworkspace -scheme $SCHEME -sdk iphoneos -configuration Release -derivedDataPath $DERIVEDDATAPATH_DIR >> /Users/seanyue/BatchBuild.log"
	if [ $? != 0 ]; then
                echo "xcodebuild faild"
                exit 1
        else
                NEXT_XCRUN=1
        fi
fi

if [ $NEXT_XCRUN == 1 ]; then
        eval "$XCRUN_EXEC -sdk iphoneos PackageApplication -v $DERIVEDDATAPATH_DIR/Build/Products/Release-iphoneos/$SCHEME.app -o $IPA_DES_DIR/$SCHEME.ipa >> /Users/seanyue/BatchBuild.log"
        if [ $? != 0 ]; then
                echo "xcrun faild"
                exit 1
        fi
fi
