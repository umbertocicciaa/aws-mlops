import sys
from awsglue.utils import getResolvedOptions
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext

glueContext = GlueContext(SparkContext.getOrCreate())

db_name = "housings"
tbl_name = "input"

args = getResolvedOptions(sys.argv,
                          ['JOB_NAME',
                           'OUTPUT_DIR',])
output_dir = "s3://" + args['OUTPUT_DIR']

housing_dyf = glueContext.create_dynamic_frame.from_catalog(database=db_name, table_name=tbl_name)

housing_df = housing_dyf.toDF()
housing_df = housing_df.dropna()

housing = DynamicFrame.fromDF(housing_df, glueContext, "nested")

glueContext.purge_s3_path(output_dir, {"retentionPeriod": 0})
glueContext.write_dynamic_frame.from_options(
    frame=housing,
    connection_type="s3",
    connection_options={"path": output_dir, "partitionOverwriteMode": "dynamic"},
    format="parquet"
)
