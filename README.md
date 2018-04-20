# Instructions

- Open a terminal and run the bash script

```bash
./scripts/qualification.sh
```
- To add a new [Spring Boot Samples project](https://github.com/spring-projects/spring-boot/tree/1.5.x/spring-boot-samples) to be tested/qualified, edit the file `projects.json` located under the `files` directory

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
