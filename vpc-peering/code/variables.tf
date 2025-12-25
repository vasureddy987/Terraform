variable "primary_region" {
  default = "ap-south-1"
}
variable "secondary_region" {
  default = "us-east-1"
}
variable "primary_cidr_block" {
  default = "10.0.0.0/16"
}
variable "secondary_cidr_block" {
  default = "10.1.0.0/16"
}
variable "primary_subnet_cidr_block" {
  default = "10.0.1.0/24"
}
variable "secondry_subnet_cidr_block" {
  default = "10.1.1.0/24"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "primary_key" {
  default = "vpc-peering-demo-south"
}
variable "secondary_key" {
  default = "vpc-peering-demo-east"
}