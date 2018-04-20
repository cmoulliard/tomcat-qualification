#!/usr/bin/env bash

CURRENT=$(pwd)
SAMPLE_REPO="https://github.com/spring-projects/spring-boot.git"
SAMPLE_PROJECT_NAME="spring-boot"
SAMPLE_REF="v1.5.12.RELEASE"
SAMPLE_DIR="spring-boot-samples"
TMP_DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
REPORT_FILE="$CURRENT/result_`date +%F`.txt"

#
# Read the qualification json file which contains the name of the project to be qualified and the endpoint to check (E.g /greeting)
#
START=0
JSONFILE=$CURRENT/files/projects.json
END=$(cat $JSONFILE | jq '.|length')

echo "File length - $JSONFILE is : $END"
#
# Git Clone Spring Boot Samples project
#
echo "TEMP DIR PATH IS : $TMP_DIR"
cd $TMP_DIR
git clone -b $SAMPLE_REF $SAMPLE_REPO && cd $SAMPLE_PROJECT_NAME

echo "==============================="
echo "Replace pom file with our"
echo "==============================="
cp $CURRENT/files/pom.xml $SAMPLE_DIR

for ((c=$START;c<=$END-1; c++ ))
do
  PROJECT_NAME=$(jq -r '.['$c'].name' $JSONFILE)
  ENDPOINT=$(jq -r '.['$c'].endpoint' $JSONFILE)

  echo "==============================="
  echo "Move to the project to be tested : $PROJECT_NAME"
  echo "==============================="
  cd $SAMPLE_DIR/$PROJECT_NAME

  echo -e "==============\n TESTING PROJECT : $PROJECT_NAME\n==============\n" >> $REPORT_FILE

  echo "==============================="
  echo "Compile and test project"
  echo "==============================="

  echo  -e "======== BEGIN test =====\n" >> $REPORT_FILE
  mvn clean test >> $REPORT_FILE
  echo  -e "======== END test =====\n" >> $REPORT_FILE

  echo -e "======== START Spring Boot =====\n" >> $REPORT_FILE
  nohup mvn spring-boot:run -Dserver.port=8989 &

  echo -e "======== Get Spring Boot PID =====\n"
  SPRING_PID=$(lsof -i:8989 -t)
  echo "Spring Boot PID is : $SPRING_PID"

  echo -e "==============================="  >> $REPORT_FILE
  echo -e "Call endpoint : $ENDPOINT"        >> $REPORT_FILE
  echo -e "==============================="  >> $REPORT_FILE
  while [ $(curl --write-out %{http_code} --silent --output /dev/null $ENDPOINT) != 200 ]
   do
     echo "Wait till we get http response 200 .... from $ENDPOINT"
     sleep 30
  done

  echo -e "==============================="  >> $REPORT_FILE
  echo "SUCCESSFULLY TESTED : Endpoint $service replied : $(curl -s $ENDPOINT)" >> $REPORT_FILE
  echo -e "==============================="  >> $REPORT_FILE

  echo -e "======== Kill Spring Boot PID =====\n"
  kill -TERM $SPRING_PID || kill -KILL $SPRING_PID

  echo "==============================="
  echo "Move up"
  echo "==============================="
  cd ..
done

#rm -rf $TMP_DIR

cd $CURRENT
