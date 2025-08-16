import awswrangler as wr
import pandas as pd
import psycopg2
import requests
from Airflow.aws_utils import new_session
from Airflow.date_utils import date_str
from airflow.models import Variable
from sqlalchemy import create_engine

API_KEY = Variable.get("API_KEY")

session = new_session


BASEURL = "https://content.guardianapis.com/search"

params = {
        'api-key': API_KEY,
        'q': 'Nigeria',
        'from-date': '2025-01-01',
        'to-date': '2025-07-30',
        'number_of_pages': 'range(1, 10)',
        'page-size':  150
}


def get_guardian_api():
    response = requests.get(BASEURL, params=params)
    if response.status_code == 200:
        data = response.json()
        article_list = data["response"]["results"]
        return article_list
    else:
        print(f"Request failed with status {response.status_code}")


def convert_data():
    total_article = []
    for article in get_guardian_api():
        total_article.append({
                "Title": article["webTitle"],
                "URL": article["webUrl"],
                "Section_name": article["sectionName"],
                "Publication_date": article["webPublicationDate"]})
    df = pd.DataFrame(total_article)
    return df


def upload_to_s3():
    df = convert_data()
    session = new_session
    new_date = date_str
    s3_bucket = 'api-guardian-project'
    s3_folder = 'new_api_folder'
    path = f"s3://{s3_bucket}/{s3_folder}/{new_date}_data_file.parquet"
    wr.s3.to_parquet(
        df=df,
        path=path,
        dataset=False,
        index=False,
        boto3_session=session
    )


def read_from_s3():
    new_date = date_str
    s3_bucket = 'api-guardian-project'
    s3_folder = 'new_api_folder'
    path = f"s3://{s3_bucket}/{s3_folder}/{new_date}_data_file.parquet"
    df = wr.s3.read_parquet(
        path=path,
        session=new_session)
    return df


def write_to_rds():
    df = read_from_s3()
    '''Write the DataFrame to an RDS PostgreSQL database'''
    username = Variable.get('rds_db_username')
    password = Variable.get('rds_db_password')
    host = Variable.get('endpoint')
    port = "5432"
    database = Variable.get('DB_NAME')

    engine = create_engine(
        f'postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}'
    )
    df.to_sql('guardian', engine, if_exists='replace', index=False)
