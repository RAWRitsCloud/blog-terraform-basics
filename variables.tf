variable "location" {
  type        = string
  description = "The Azure Datacentre location."
  default     = "uksouth"
}

variable "loc_short" {
  type        = string
  description = "Short name for the Azure Datacentre location."
  default     = "uks"
}

variable "prefix" {
  type        = string
  description = "My prefix for my resources for consitent naming conventions."
  default     = "rawr"
}

# Locals are like Variables however you can use Terraform functions in Locals.
locals {
  vmprefix = join("",[var.prefix,var.loc_short])
}