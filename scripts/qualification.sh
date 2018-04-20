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

  cd $SAMPLE_DIR/$PROJECT_NAME

  echo -e "========================================================\n Test executed : $(date) \n========================================================\n" > $REPORT_FILE
  echo -e "========================================================\n QUALIFYING PROJECT : $PROJECT_NAME\n========================================================\n" >> $REPORT_FILE

  echo  -e "======== STEP 1 : BEGIN test =====\n" >> $REPORT_FILE
  mvn clean test >> $REPORT_FILE
  echo  -e "======== STEP 1 : END test =====\n" >> $REPORT_FILE

  echo -e "======== STEP 2 : Start Spring Boot =====\n" >> $REPORT_FILE
  nohup mvn spring-boot:run -Dserver.port=8989 &
  sleep 30
  SPRING_PID=$(lsof -i:8989 -t)

  echo -e "Call endpoint : $ENDPOINT" >> $REPORT_FILE
  while [ $(curl --write-out %{http_code} --silent --output /dev/null $ENDPOINT) != 200 ]
   do
     echo "Wait till we get http response 200 .... from $ENDPOINT" >> $REPORT_FILE
     sleep 30
  done
  echo -e "Endpoint $service replied : $(curl -s $ENDPOINT)\n" >> $REPORT_FILE
  echo -e "$PROJECT_NAME Test - Result\n" >> $REPORT_FILE

  kill $SPRING_PID
  echo -e "============ STEP 2 : Spring Boot Stopped ===================\n"  >> $REPORT_FILE
  echo -e "========================================================\n END QUALIFYING PROJECT : $PROJECT_NAME\n========================================================\n" >> $REPORT_FILE

  cd ..
done

rm -rf $TMP_DIR

cd $CURRENT
