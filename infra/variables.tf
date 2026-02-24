variable "region" {
	type = string
	default = "us-east-1"
}

variable "prefix" {
	type = string
	default = "techno"
}

variable "environment" {
	type = string
	default = "Production"
}

variable "name" {
	type = string
	default = "walidi-danang"
}

variable "city" {
	type = string
	default = "blitar"
}

variable "labRoleARN" {
	type = string
	default = "arn:aws:iam::975050048219:role/LabRole"
}

variable "adminEmail" {
	type = string
	default = "walididanang463@gmail.com"
}
