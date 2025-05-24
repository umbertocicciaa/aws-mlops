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
output_dir = "s3://" + args['OUTPUT_DIR']

# Read data into a DynamicFrame using the Data Catalog metadata
housing_dyf = glueContext.create_dynamic_frame.from_catalog(database=db_name, table_name=tbl_name)

# Remove records with missing values
housing_df = housing_dyf.toDF()
housing_df = housing_df.dropna()

# Turn it back to a dynamic frame
housing = DynamicFrame.fromDF(housing_df, glueContext, "nested")

# Write it out in Parquet
glueContext.write_dynamic_frame.from_options(frame=housing, connection_type="s3", connection_options={"path": output_dir}, format="parquet")
