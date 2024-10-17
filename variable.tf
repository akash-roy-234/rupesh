variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "location" {
  description = "Azure region where the resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "sequentra-lb-prod-rg"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "sequentra-lb-prod-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "sequentra-lb-prod"
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "The size of the VM for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "lb_public_ip_name" {
  description = "Name of the Public IP for the Load Balancer"
  type        = string
  default     = "sequentra-lb-prod-ip"
}

variable "lb_name" {
  description = "Name of the Load Balancer"
  type        = string
  default     = "sequentra-lb-prod-ALB"
}

variable "lb_backend_pool_name" {
  description = "Name of the Backend Pool for the Load Balancer"
  type        = string
  default     = "sequentra-lb-prod-backendpool"
}

variable "lb_probe_name" {
  description = "Name of the Health Probe for the Load Balancer"
  type        = string
  default     = "sequentra-lb-prod-probe"
}

variable "lb_rule_name" {
  description = "Name of the Load Balancer Rule"
  type        = string
  default     = "sequentra-lb-prod-rule"
}

variable "namespace_name" {
  description = "Kubernetes namespace"
  type        = string
  default     = "sequentra-lb-prod"
}

variable "deployment_name" {
  description = "Name of the Kubernetes Deployment"
  type        = string
  default     = "sequentra-lb-prod-ecs-service"  # Ensure all lowercase and no special characters
}

variable "replicas" {
  description = "Number of replicas for the Kubernetes Deployment"
  type        = number
  default     = 1
}

variable "service_name" {
  description = "Name of the Kubernetes Service"
  type        = string
  default     = "sequentra-lb-prod-service"
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {
    environment = "test"
    owner       = "sequentra-team"
  }
}
