#!/usr/bin/env python

# return a list of all intends a file given as first argument is using

from argparse import ArgumentParser

import sys
import os
sys.path.append("/home/reox/tools/androguard/") 

from androguard.core.bytecodes import dvm, apk


parser = ArgumentParser()
parser.add_argument("-f", "--file", dest="filename", help="The APK Path you want to analyse", metavar="FILE",required=True, nargs="+")
parser.add_argument("-r", "--print-receivers", dest="prec", action='store_true', help="Print out all Receivers and Exit")
parser.add_argument("-p", "--print-providers", dest="ppro", action='store_true', help="Print out all Providers and Exit")
parser.add_argument("-i", "--print-intents", dest="pint", action='store_true', help="Print out all Providers and Exit")
parser.add_argument("-m", "--manifest", dest="mani", action='store_true', help="Print out RAW Manifest")
parser.add_argument("-x", "--permissions", dest="perm", action='store_true', help="Print out Permissions")
parser.add_argument("-av", "--android-version", dest="aver", action='store_true', help="Gets the APK Version Number (App Version)")
parser.add_argument("-ap", "--android-package", dest="apack", action='store_true', help="Gets the APK Package Name")
parser.add_argument("-ac", "--android-code", dest="acode", action='store_true', help="Gets the APK Version Code (App Version)")
parser.add_argument("-va", "--view-activity", dest="va", action='store_true', help="Gets the APK's View Activity")
parser.add_argument("-ma", "--main-activity", dest="ma", action='store_true', help="Gets the APK's Main Activity")

args = parser.parse_args()

for apk_file in args.filename:
    if os.path.isdir(apk_file) == False:
        a = apk.APK(apk_file)
# Some Command Line Arguments for just looking inside
        if args.prec:
            for item in a.get_receivers():
                print item
            sys.exit(0)

        if args.ppro:
            for item in a.get_providers():
                print item
            sys.exit(0)

        if args.pint:
            for i in a.xml :
                intents = set()
                for item in a.xml[i].getElementsByTagName("receiver") :
                    for sitem in item.getElementsByTagName( "action" ) :
                        # the method containing the intent is in this xml attr
                        #print item.getAttribute("android:name")
                        # the intent which is used is in this xml attr
                        #print "    "+sitem.getAttribute("android:name")
                        intents.add( sitem.getAttribute( "android:name" ) )

            for intent in intents:
                print intent
            sys.exit(0)

        if args.perm:
            for i in a.xml :
                perms = set()
                for item in a.xml[i].getElementsByTagName("uses-permission") :
                    for perm in perms:
                        print item.getAttribute( "android:name" )

            sys.exit(0)

        if args.mani:
            for i in a.xml:
                print a.xml[i].toxml()

        # parse some general informations from the APK file
        for i in a.xml:
            versions = set()
            man_node = a.xml[i].getElementsByTagName("manifest")
            for manifest in man_node:
                if args.aver:
                    print manifest.getAttribute("android:versionName")
                if args.apack:
                    print manifest.getAttribute("package")
                if args.acode:
                    print manifest.getAttribute("android:versionCode")
                   
        if args.va:
            for i in a.xml :
                for item in a.xml[i].getElementsByTagName("activity") :
                    for sitem in item.getElementsByTagName( "action" ) :
                        if sitem.getAttribute("android:name") == "android.intent.action.VIEW":
                            print item.getAttribute( "android:name" )
                            sys.exit(0)

        if args.ma:
            for i in a.xml :
                for item in a.xml[i].getElementsByTagName("activity") :
                    for sitem in item.getElementsByTagName( "action" ) :
                        if sitem.getAttribute("android:name") == "android.intent.action.MAIN":
                            print item.getAttribute( "android:name" )
