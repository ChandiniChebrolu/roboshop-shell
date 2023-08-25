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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $Logfile
validate $? "setting up the npm source" 
yum install nodejs -y&>> $Logfile
validate $? "installing nodejs"
useradd roboshop&>> $Logfile
validate $? "adding user"
mkdir /app 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $Logfile
validate $? "downloading catalogue artifact"
cd /app 
validate $? "moved to app directory"
unzip /tmp/catalogue.zip &>> $Logfile
validate $? "unzipping catalogue artifact"

npm install &>> $Logfile
validate $? "installing dependences"

cp catalogue.service /etc/systemd/system/catalogue.service &>> $Logfile
validate $? "copied cataogue.service to systemd"
systemctl daemon-reload &>> $Logfile
validate $? "daemon reloading"

systemctl enable catalogue &>> $Logfile
validate $? "enableing catalogue"
systemctl start catalogue &>> $Logfile
validate $? "starting catalogue"
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $Logfile
validate $? "copying mongo.repo"

yum install mongodb-org-shell -y &>> $Logfile
validate $? "installing mongo client"
mongo --host 54.81.178.33 </app/schema/catalogue.js &>> $Logfile
validate $? "loading catalogue data in to mongodb"

