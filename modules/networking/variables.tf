variable "vpc_cidr" {}
variable "name_prefix" {}
variable "tags" {}

# Inside modules/networking, Terraform behaves as if the following existed:
# # (conceptual, NOT written by you)

# var.vpc_cidr    = "10.0.0.0/16"
# var.name_prefix = "ai-agency"
# var.tags = {
#   Environment = "dev"
#   Project     = "ai-agency"
# }

# This is the mental model you should keep.