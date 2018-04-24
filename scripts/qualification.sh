#!/usr/bin/env bash

#
# Pre-req
# jq, python2, python websocket-client, xml are installed
#

function generateStatusResult() {
  if [[ $RESULT = *$RESPONSE* ]]; then
    STEP2_RESULT="Endpoint query result : Success : Endpoint $ENDPOINT replied : $RESULT\n"
  else
    STEP2_RESULT="Endpoint query result : Failing : Endpoint $ENDPOINT replied : $RESULT but we were expecting : $RESPONSE\n"
  fi
}

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
JSONFILE=${1:-$CURRENT/files/projects.json}
END=$(cat $JSONFILE | jq '.|length')

#
# Git Clone Spring Boot Samples project
#
# echo "TEMP DIR PATH IS : $TMP_DIR"
cd $TMP_DIR
git clone -b $SAMPLE_REF $SAMPLE_REPO && cd $SAMPLE_PROJECT_NAME

echo "==============================="
echo "Replace pom file with our"
echo "==============================="
cd $SAMPLE_DIR
cp $CURRENT/files/pom.xml .

COUNTER=1
echo -e "========================================================\n Test executed : $(date) \n========================================================\n" > $REPORT_FILE

for ((c=$START;c<=$END-1; c++ ))
do
  PROJECT_NAME=$(jq -r '.['$c'].name' $JSONFILE)
  PROJECT_TITLE=$(jq -r '.['$c'].title' $JSONFILE)
  ENDPOINT=$(jq -r '.['$c'].endpoint' $JSONFILE)
  RESPONSE=$(jq -r '.['$c'].response' $JSONFILE)
  CONTAINER_PORT=$(jq -r '.['$c'].port' $JSONFILE)
  STATUS=$(jq -r '.['$c'].status' $JSONFILE)
  USERNAME=$(jq -r '.['$c'].username' $JSONFILE)
  PASSWORD=$(jq -r '.['$c'].password' $JSONFILE)

  cd $PROJECT_NAME

  echo -e "========================================================\n $COUNTER - QUALIFYING PROJECT : $PROJECT_NAME\n========================================================\n"
  echo -e "========================================================\n $COUNTER - QUALIFYING PROJECT : $PROJECT_NAME\n========================================================\n" >> $REPORT_FILE
  echo -e "======== STEP 1 : BEGIN test =====\n" >> $REPORT_FILE
  # mvn dependency:tree | grep tomcat
  MVN_TEST_RESULT=$(mvn clean test)
  TEST_STATUS=$(echo "$MVN_TEST_RESULT" | grep '\[INFO\] BUILD SUCCESS')

  if [ -z "$TEST_STATUS" ]; then
        STEP1_RESULT="Maven Test result : Failing"
  else
        STEP1_RESULT="Maven Test result : Success"
  fi

  echo  -e "======== STEP 1 : END test =====\n" >> $REPORT_FILE

  echo -e "======== STEP 2 : Start Spring Boot =====\n" >> $REPORT_FILE
  case $PROJECT_NAME in
    *"war"*)
      mvn clean package
      nohup java -jar target/*.war &
      sleep 30
      SPRING_PID=$(lsof -i:$CONTAINER_PORT -t)
      ;;
    *)
      nohup mvn spring-boot:run -Dserver.port=$CONTAINER_PORT &
      sleep 30
      SPRING_PID=$(lsof -i:$CONTAINER_PORT -t)
      ;;
  esac

  case $PROJECT_NAME in
    *"websocket"*)
       echo "# THIS IS A WEBSOCKET PROJECT"
       # Call the Websocket and Capture the response
       RESULT=$(python $CURRENT/scripts/call_websocket.py $ENDPOINT)
       generateStatusResult $RESULT $RESPONSE $ENDPOINT
       ;;
    *"secure"*)
       echo "# THIS IS A SECURED PROJECT"
       # Call the auth_csrf.py script and Capture the response
       RESULT=$(python $CURRENT/scripts/call_auth_csrf.py $ENDPOINT $USERNAME $PASSWORD)
       generateStatusResult $RESULT $RESPONSE $ENDPOINT
       ;;
    *"webservices"*)
       echo "# THIS IS A WEBSERVICE PROJECT"
       # Call the call_websocket.py and Capture the response
       RESULT=$(python $CURRENT/scripts/call_WS.py $ENDPOINT $CURRENT/files/soap.xml)
       generateStatusResult $RESULT $RESPONSE $ENDPOINT
       ;;
    *)
     echo "# THIS IS A HTTP/HTTPS PROJECT"

     # Add parameter for curl if protocol is https
     if [[ $ENDPOINT = *"https"* ]]; then CURL_PARAMS="-k"; fi

     # Call the http endpoint ans wait till we get a response
     echo -e "Call endpoint : $ENDPOINT" >> $REPORT_FILE
     if [ "$DEBUG_SCRIPT" ]; then echo "curl $CURL_PARAMS --write-out %{http_code} --silent --output /dev/null $ENDPOINT"; fi

     while [ $(curl $CURL_PARAMS --write-out %{http_code} --silent --output /dev/null $ENDPOINT) != $STATUS ]
      do
        echo "Wait till we get http response $STATUS .... from $ENDPOINT" >> $REPORT_FILE
        sleep 30
     done
     RESULT=$(curl $CURL_PARAMS -s $ENDPOINT)
     generateStatusResult $RESULT $RESPONSE $ENDPOINT
     ;;
  esac

  # Kill Spring Boot Application process
  kill $SPRING_PID
  echo -e "======== STEP 2 : Spring Boot Stopped ===================\n"  >> $REPORT_FILE

  echo -e "======= !!!! Report Result !!!! ========================\n"  >> $REPORT_FILE
  echo -e "Project : $PROJECT_TITLE\n" >> $REPORT_FILE
  echo -e "Step 1: $STEP1_RESULT" >> $REPORT_FILE
  echo -e "Step 2: $STEP2_RESULT" >> $REPORT_FILE

  echo -e "========================================================\n $COUNTER - END QUALIFYING PROJECT : $PROJECT_NAME\n========================================================\n"
  echo -e "========================================================\n $COUNTER - END QUALIFYING PROJECT : $PROJECT_NAME\n========================================================\n" >> $REPORT_FILE

  cd ..
  COUNTER=$[$COUNTER +1]
done

rm -rf $TMP_DIR

cd $CURRENT
