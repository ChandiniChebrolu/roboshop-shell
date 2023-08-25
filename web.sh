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
yum list installed nginx
if [ $?-ne 0 ]
then
 yum install nginx -y
 validate $? "installing nginx"
else
 echo "already installed"
fi
systemctl enable nginx
validate $? "enableing nginx"
systemctl start nginx
validate $? "starting nginx"
#http://34.226.222.125:80
#validate $? "checking the default nginx server"
rm -rf /usr/share/nginx/html/*
validate $? "removing default content"
curl -o /tmp/frontend.zip https://roboshop-builds.s3.amazonaws.com/web.zip
validate $? "installing frontend artifact"
cd /usr/share/nginx/html
validate $? "moving in to html directory"
unzip /tmp/frontend.zip
validate $? "unzipping the artifact"
cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf 
validate $? "copying to default.d"
systemctl restart nginx
validate $? "restarting nginx"