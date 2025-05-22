import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext

glueContext = GlueContext(SparkContext.getOrCreate())

# Glue Data Catalog: database and table name
db_name = "housings"
tbl_name = "input"

# S3 location for output
args = getResolvedOptions(sys.argv,
                          ['JOB_NAME',
                           'OUTPUT_DIR',])
output_dir = args['OUTPUT_DIR']

# Read data into a DynamicFrame using the Data Catalog metadata
housing_dyf = glueContext.create_dynamic_frame.from_catalog(database=db_name, table_name=tbl_name)

# Remove records with missing values
housing_df = housing_dyf.toDF()
housing_df = housing_df.dropna()

# Turn it back to a dynamic frame
housing_tmp = DynamicFrame.fromDF(housing_df, glueContext, "nested")

# Rename, cast, and nest with apply_mapping
medicare_nest = housing_tmp.apply_mapping([('longitude', 'double', 'location.longitude', 'double'),
                                            ('latitude', 'double', 'location.latitude', 'double'),
                                            ('housing_median_age', 'double', 'housing.age', 'double'),
                                            ('total_rooms', 'double', 'housing.total_rooms', 'double'),
                                            ('total_bedrooms', 'double', 'housing.total_bedrooms', 'double'),
                                            ('population', 'double', 'housing.population', 'double'),
                                            ('households', 'double', 'housing.households', 'double'),
                                            ('median_income', 'double', 'income.median', 'double'),
                                            ('median_house_value', 'double', 'price.median', 'double'),
                                            ('ocean_proximity', 'string', 'location.ocean_proximity', 'string')])

# Write it out in Parquet
glueContext.write_dynamic_frame.from_options(frame=medicare_nest, connection_type="s3", connection_options={"path": output_dir}, format="parquet")
