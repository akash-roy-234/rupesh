provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create an AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

# Create a Public IP for the Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = var.lb_public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Load Balancer for the AKS Cluster
resource "azurerm_lb" "aks_lb" {
  name                = var.lb_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Backend Pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.aks_lb.id
  name            = var.lb_backend_pool_name
}

# Health Probe for Load Balancer
resource "azurerm_lb_probe" "lb_probe" {
  name            = var.lb_probe_name
  loadbalancer_id = azurerm_lb.aks_lb.id
  protocol        = "Http"
  port            = 80
  request_path    = "/health"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load Balancer Rule
resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.aks_lb.id
  name                           = var.lb_rule_name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

# Create a Kubernetes namespace to match ECS namespacing
resource "kubernetes_namespace" "sequentra_ns" {
  metadata {
    name = var.namespace_name
  }
}

# Example deployment for an application in AKS to replicate ECS task
resource "kubernetes_deployment" "sequentra_app" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.sequentra_ns.metadata[0].name
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "sequentra-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "sequentra-app"
        }
      }

      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Expose the Kubernetes deployment with a service (similar to AWS ECS Service)
resource "kubernetes_service" "sequentra_service" {
  metadata {
    name      = var.service_name
    namespace = kubernetes_namespace.sequentra_ns.metadata[0].name
  }

  spec {
    selector = {
      app = "sequentra-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
