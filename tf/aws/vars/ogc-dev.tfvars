region = "us-west-2"
# name gets suffixed with `-${cluster_version}`
cluster_name = "ogc-eoapi"
cluster_version = "dev"
prometheus_hostname = ""
instance_type = "t3.xlarge"
enable_efs = true
bucket_names = ["ogc-veda-data-store",]
