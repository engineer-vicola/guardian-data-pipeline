from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator

from utils_api import get_guardian_api, convert_data, upload_to_s3, read_from_s3, write_to_rds


default_args = {
    'owner': 'data_engineering_project',
    'retries': 2
}

dag = DAG(
    dag_id="full_api_job",
    description="Fetching the data from the guardian API",
    schedule="@daily",
    start_date=datetime(2025, 7, 22),
    catchup=False,
    default_args=default_args
)

extract_data = PythonOperator(
    python_callable=get_guardian_api,
    task_id="extract_data",
    dag=dag,
)


converted_data = PythonOperator(
    python_callable=convert_data,
    task_id="converted_data",
    dag=dag
)

write_to_s3 = PythonOperator(
    python_callable=upload_to_s3,
    task_id="write_to_s3",
    dag=dag
)

get_data_from_s3 = PythonOperator(
    python_callable=read_from_s3,
    task_id="get_data_from_s3",
    dag=dag
)

send_to_rds = PythonOperator(
    python_callable=write_to_rds,
    task_id="send_to_rds",
    dag=dag
)


extract_data >> converted_data >> write_to_s3 >> get_data_from_s3 >> send_to_rds