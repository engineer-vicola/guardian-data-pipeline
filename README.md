**Guardian API Project**


**Overview**

This project implements a fully automated data pipeline that fetches data from a public API (guardian API) on a daily basis, stores it in Amazon S3, 
the database is managed by relational database service and sent to datawarehouse (Redshift).
The infrastructure is provisioned using Terraform, while the workflow is managed and scheduled via Apache Airflow.


**Tech Stack**

Python

Apache Airflow – Workflow orchestration

Terraform – Infrastructure as code

AWS S3 – Storage layer

Relational Database Service - database management 

AWS IAM – Access control

AWS Systems Manager (SSM) – Secure credentials storage

Images from the project;

![Image](https://github.com/user-attachments/assets/b0b2a143-7827-404c-b3cf-e60846838a0f)
![Image](https://github.com/user-attachments/assets/e0e49edd-b460-4e8a-b168-2104fa707f10)


