# Instructions

## Prerequisites

- Command line JSON processor - [jq](https://stedolan.github.io/jq/),
- [Python2](https://www.python.org/downloads/) interpreter is installed 
- Python [websocket-client](https://pypi.org/project/websocket-client/)

## Goals of the project

The goal of this project is to test a collection of Spring Boot applications, part of the Spring Boot upstream project and
to test them using the Apache Tomcat `8.0.36` embedded container

The bash script `qualification.sh` will perform the following steps :

- Download the branch `v1.5.12.RELEASE` of the Spring Boot project
- Replace the `pom.xml` file of the `spring-boot-samples` folder with our which contains the `Apache Tomcat 8.0.x` dependencies
- For each entry, project defined within the json file `projects.json`, execute these instructions :
  - Run `mvn clean test` and store the result within `step1_result` to check if the status of the maven test is `successfull` or `failure`
  - Start in background a `spring-boot` application, call the `endpoint` of the project or web page to get a response. Keep the result saved under `step1_result` to validate the response
- Save the result of step1, step2 within the report `result_DATE.txt` file  

-**NOTE** : To add a new [Spring Boot Samples project](https://github.com/spring-projects/spring-boot/tree/1.5.x/spring-boot-samples) to be tested/qualified, edit the file `projects.json` located under the `files` directory

## Use cases tested

| Name | Description | Category |
|------|-------------|----------|
| spring-boot-sample-tomcat | Spring Boot Application with REST @Controller and @Component Service | HTTP Connector and REST |
| spring-boot-sample-tomcat80-ssl | Spring Boot TLS/SSL Application with REST @Controller and @Component Service | SSL/TLS |
| spring-boot-sample-tomcat-jsp | Spring Boot JSP & JSTL web Application | JSP/JSTL | 
| spring-boot-sample-websocket-tomcat | Spring Boot Websocket Application | Websocket | 
| spring-boot-sample-traditional | Spring Boot traditional MVC & JSP application (WEB-INF,web.xml,jsp) | JSP, war packaging | 
| spring-boot-sample-multiconnectors* | Spring Boot application with 2 connectors (Http11NioProtocol, TLS) | MultiConnectors (TLS, NIO) |
| spring-boot-sample-webservices** | Spring Boot Webservice application | Webservice | 

*: It can't be tested as the sample project uses a random port to start the Web NIO Connector. Then, the project must be tested manually
*: It can't be tested as the sample project don't return a response to a curl req. Then, the project must be tested manually

## Execute the Job testing/qualifying the samples

- Open a terminal and run the bash script

```bash
./scripts/qualification.sh
```

- Consult the report generated within the current folder and specifically these section

```bash
========================================================
 Test executed : Fri Apr 20 16:01:11 CEST 2018 
========================================================

========================================================
 1 - QUALIFYING PROJECT : spring-boot-sample-tomcat
========================================================

======== STEP 1 : BEGIN test =====

======== STEP 1 : END test =====

======== STEP 2 : Start Spring Boot =====

Call endpoint : http://localhost:8989/
======== STEP 2 : Spring Boot Stopped ===================

======= !!!! Report Result !!!! ========================

Project : PROJECT_TITLE

Step 1: Maven Test result : Success
Step 2: Endpoint query result : Success : Endpoint http://localhost:8989/ replied : Hello World

========================================================
 1 - END QUALIFYING PROJECT : spring-boot-sample-tomcat
========================================================

========================================================
 2 - QUALIFYING PROJECT : spring-boot-sample-tomcat80-ssl
========================================================

======== STEP 1 : BEGIN test =====

======== STEP 1 : END test =====

======== STEP 2 : Start Spring Boot =====

Call endpoint : https://localhost:8443/
======== STEP 2 : Spring Boot Stopped ===================

======= !!!! Report Result !!!! ========================

Project : PROJECT_TITLE

Step 1: Maven Test result : Success
Step 2: Endpoint query result : Success : Endpoint https://localhost:8443/ replied : Hello, world

========================================================
 2 - END QUALIFYING PROJECT : spring-boot-sample-tomcat80-ssl
========================================================
...
```
