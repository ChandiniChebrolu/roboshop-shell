#!/bin/bash
Logdir=/tmp
script_name=$0
Date=$(date +%F:%H:%M:%S)
Logfile=$Logdir/$0-$Date.log
USERID=$(id -u)
if [ $USERID -ne 0 ]
then
 echo "please run the script with root user"
 exit 1
fi
validate() {
  if [ $1 -ne 0 ]
  then
   echo "$2.. failed"
   exit 1
  else
   echo "$2.. Success"
  fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $Logfile
validate $? "copied mongo.repo in to yum.repos.d"
yum install mongodb-org -y &>> $Logfile
validate $? "installation of mangodb"
systemctl enable mongod &>> $Logfile
validate $? "enableing mongodb"
systemctl start mongod &>> $Logfile
validate $? "starting mongodb"
sed -i "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf &>> $Logfile
validate $? "edited mongodb conf"
systemctl restart mongod &>> $Logfile
validate $? "restarting mongodb"