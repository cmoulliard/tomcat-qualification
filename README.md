# Instructions

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

## Run the bash script to test the Spring Boot Samples Git hub project using the Tomcat 8.0 dependencies

- Open a terminal and run the bash script

```bash
./scripts/qualification.sh
```

- Consult the report generated within the current folder and specifically the section

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

```
