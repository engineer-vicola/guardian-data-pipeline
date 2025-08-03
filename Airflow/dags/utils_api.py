import boto3
import pandas as pd
import awswrangler as wr
import requests
import psycopg2
from datetime import datetime
from sqlalchemy import create_engine
from airflow.models import Variable


# extraction for API
API_KEY = Variable.get("API_KEY")

session = boto3.session.Session(
                aws_access_key_id=Variable.get("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=Variable.get("AWS_SECRET_ACCESS_KEY"),
                region_name='us-east-1' 
            )


BASEURL = "https://content.guardianapis.com/search"

params= {
        'api-key': API_KEY,
        'q':'Nigeria',
        'from-date':'2025-01-01',
        'to-date':'2025-07-30',
        'number_of_pages':'range(1, 10)',
        'page-size': 150
}

# Create a function


def get_guardian_api():
    response = requests.get(BASEURL, params=params)
    data = response.json()
    article_list = data["response"]["results"]
    return article_list

# convert to dataframe.


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


# upload to s3.
def upload_to_s3():
    df = convert_data()
    session = boto3.session.Session(
                aws_access_key_id=Variable.get("AWS_ACCESS_KEY_ID"),
                aws_secret_access_key=Variable.get("AWS_SECRET_ACCESS_KEY"),
                region_name='us-east-1' 
            )
    date_str = datetime.today().strftime('%Y-%m-%d')
    s3_bucket = 'api-guardian-project'
    s3_folder = 'new_api_folder'
    path = f"s3://{s3_bucket}/{s3_folder}/{date_str}_data_file.parquet" 
    
    wr.s3.to_parquet(
        df=df,
        path=path,
        dataset=False,
        index=False,
        boto3_session=session
    )


# Read the DataFrame from S3
def read_from_s3():
   date_str = datetime.today().strftime('%Y-%m-%d')
   s3_bucket = 'api-guardian-project'
   s3_folder = 'new_api_folder'
   path=f"s3://{s3_bucket}/{s3_folder}/{date_str}_data_file.parquet" 
   
   df= wr.s3.read_parquet(
        path= path,
        boto3_session = boto3.Session(
        aws_access_key_id=Variable.get("AWS_ACCESS_KEY_ID"),
        aws_secret_access_key=Variable.get("AWS_SECRET_ACCESS_KEY"),
        region_name='us-east-1' 
        ) 
   )   
   return df

# create engine
def write_to_rds():
    df=read_from_s3()
    '''Write the DataFrame to an RDS PostgreSQL database'''
    username = Variable.get('rds_db_username')
    password = Variable.get('rds_db_password')
    host = Variable.get('endpoint')
    port = "5432"
    database = Variable.get('DB_NAME')

    engine = create_engine(f'postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}')
    df.to_sql('guardian', engine, if_exists='replace', index=False)

    print("successfuly loaded")