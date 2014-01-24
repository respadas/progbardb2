#!/usr/bin/bash # progbardb2.sh 
# Ugly bash script for make simple db2 backups and see the amount of progress with a progress bar 
# Author: Ruben Espadas (me [at] respadas [dot] net) 
# Idea of progress bar taken from ksaver script 
# License: BSD # April 30, 2012 

DB="" 
DBPATH="" 
ENDSTR="" 
PERCENT=0 
BAR="" 
PROMPT=">" 
LAST=0 

if [ $# -lt 2 ] || ([ $# -lt 3 ] && ([ "$1" == "-c" ] || [ "$1" == "--compress" ])) 
then 
 echo "Usage: $0 [OPTION] DATABASE PATH" 
 echo " -c, --compress compress backup" 
 exit 
fi 

if [ "$1" == "-c" ] || [ "$1" == "--compress" ] 
then 
 DB=$2
 DBPATH=$3
 ENDSTR="compress"
else
 DB=$1
 DBPATH=$2
fi

if [ -w $DBPATH ]
then
 DBINST=$(db2 list database directory | grep $DB | grep name | awk '{print $4}')
 if [ "$DB" != "$DBINST" ]
 then
 echo "Database not found"
 exit
 fi
 else
 echo "I can't write in $DBPATH, check the user, owners dir and permissions"
 exit
fi

function progr_bar()
{
STARTDB=$(db2 backup database $DB to $DBPATH $ENDSTR)&
STARTDB=$(echo $STARTDB | awk '{print $8}')
if [ "$STARTDB" == "SQLSTATE=57019" ]
then
 echo "The database is currently in use, try again after turn off systems."
 exit 
fi 

write_percent 

while [ $PERCENT -lt 100 ] 
do 
 PERCENT=$(db2 list utilities show detail | grep Percentage | awk '{print $5}')
 if [ -z $PERCENT ] || [ $PERCENT -eq 0 ]
 then 
 let PERCENT=0 
 elif [ $LAST -ne $PERCENT ] 
 then 
 write_percent
 LAST=$PERCENT
 fi
done
echo -e " Respaldo finalizado.\n" 
} 

function write_percent() 
{ 
echo -ne "\r\t[ " 
echo -ne "$BAR$PROMPT ] $PERCENT% " 
BAR="${BAR}=" 
} 

progr_bar 
