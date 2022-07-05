terraform {
  ### Minimum terraform version required for planning and applying the resources
  required_version = "1.1.6"
  required_providers {
    ### Minimum Hashicorp/AWS Provider version
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.3"
    }
  }
}


