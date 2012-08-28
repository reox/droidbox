#!/usr/bin/env bash
# vim:foldmethod=marker autoindent expandtab shiftwidth=4

# TODO 
# * Use Androguard
# * Use dexid to determinate common malicious code
# * Use androguard signatures to check for known issues

# {{{ Settings

ANDROGUARD=/home/android/git/androguard
ANDRORISK=/home/android/git/androrisk
export PYTHONPATH=$PYTHONPATH:$ANDROGUARD/elsim:$ANDROGUARD/androguard
SIMILARITIES="/home/android/git/androsign/samples/*"
IGNOREAPI="(Lcom/android/.*)|(Lcom/paypal/.*)|(Lcom/google/.*)|(Lcom/openfeint/.*)|(Landroid/.*)|(Ljava/.*)|(Ljavax/.*)|(Lcom/sun/.*)|(Lorg/apache/.*)|(Lorg/springframework/*)"
IGNOREADS="(Lcom/adwhirl/.*)|(Lcom/appssavvy/sdk/.*)|(Lcom/flurry/android/.*)|(Lcom/zong/android/.*)|(Lcom/greystripe/.*)|(Lcom/inneractive/api/.*)|(Lcom/millennialmedia/android/.*)|(Lcom/mdotm/android/.*)|(Lcom/admob/android/.*)"
SIMLOG=simlog

# }}} End Settings

# {{{ Functions

function title {
    length=$((${#1}+2))
    total=60
    side=$(((total-length)/2))

    for i in $(seq 0 $side); do
        echo -n "="
    done
    echo -n " $1 "
    for i in $(seq 0 $side); do
        echo -n "="
    done
    echo ""
}


# }}} End Functions

# {{{ Option Parsing
DEX=
APK=
SIMAPI=
SIMADS=
while true ; do
    case "$1" in
        -f|--file) DEX=$2; APK=$2 ; shift 2; break ;;
        --noapi) SIMAPI=1; shift 2; break ;;
        --noads) SIMADS=1; shift 2, break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# }}} End Option Parsing

# {{{ Main Programm

isDex=$(file $APK | grep -o dex)

if [ "foo$isDex" != "foodex" ]; then
    # the file is an apk file, so do additional checks
    unzip $APK classes.dex
    DEX="classes.dex"
    
    title "General Info"
    # print some general information
    echo -n "Package Name: "
    ./getAPKInformation.py -ap -f $APK
    echo -n "Package Version: "
    ./getAPKInformation.py -av -f $APK

    echo -n "APK MD5: "
    md5sum $APK
    echo -n "DEX MD5: " 
    md5sum $DEX

    title "Intents"
    ./getAPKInformation.py -i -f $APK

    title "Permissions"
    ./getAPKInformation.py -x -f $APK
fi

title "Risky Methods"
$ANDRORISK/androrisk.py -a -m -i $DEX | egrep '^.* [1-9][0-9]+\.(0|[0-9]+)$'

title "Overall Risk"
$ANDRORISK/androrisk.py -a -i $DEX


title "Similarities"
for sim in $SIMILARITIES; do
    echo "Compare with $(md5sum $sim)"
    [ -z "$SIMAPI" -a -z "$SIMADS" ] || exclude="-e "
    [[ -z "$SIMAPI" ]] || exclude="$exclude$IGNOREAPI"
    [[ -z "$SIMADS" ]] || exclude="$exclude$IGNOREADS"
    $ANDROGUARD/androsim.py -t 0.1 -s 10 -c ZLIB -n $exclude -i $DEX $sim -d | tee -a $SIMLOG |head -n 7 | grep -v "Elements" | grep -v "DELETED" | grep -v "NEW"
done 2>/dev/null

title "Adware Scan"
$ANDROGUARD/androsign.py -i $DEX -b $ANDROGUARD/signatures/adwaredb -c $ANDROGUARD/signatures/dbconfig

rm classes.dex

# }}} End Main Programm
