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
![Image](https://github.com/user-attachments/assets/5a45ce9b-ad5d-492f-bfef-464e46a5d76f)
![Image](https://github.com/user-attachments/assets/89412f6d-f757-48c3-8b19-6baa2a245e27)
![Image](https://github.com/user-attachments/assets/f96ff7d8-644c-4f6f-9b73-32d6e96edb44)
![Image](https://github.com/user-attachments/assets/a78c1903-2365-4ab3-b77b-381f2f912a96)

