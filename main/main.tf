provider "aws" {
    region = var.region
    profile = var.profile
}

### Creating the VPC and the subnetework  ###
module "network" {
    source = "../module/network"
    region = "us-east-1"
    environment = "devlopment"
}

module "security" {
    source = "../module/security"
    vpc = module.network.vpc
    vpc_id = module.network.vpc_id
    environment = "devlopment"
}

module "elasticcache"{
    source = "../module/elasticcache"
}

module "s3" {
    source = "../module/s3"
}

module "cloudfront"{
    source = "../module/cloudfront"
}

# module "dynamodb" {
#     source = "../module/dynamodb"
# }

# module "opswork" {
#     source = "../module/opswork"
# }

module "ecs"{
    source = "../module/ecs"
    vpc_id = module.network.vpc_id
}