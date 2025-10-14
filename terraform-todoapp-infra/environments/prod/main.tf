locals {
  common_tags = {
    "ManagedBy"   = "Terraform"
    "Owner"       = "microtaskerTeam"
    "Environment" = "prod"
  }
}

module "rg" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "rg-prod-microtasker"
  rg_location = "centralindia"
  rg_tags     = local.common_tags
}

module "rg1" {
  source      = "../../modules/azurerm_resource_group"
  rg_name     = "rg-prod-microtasker-1"
  rg_location = "centralindia"
  rg_tags     = local.common_tags
}

module "acr" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_container_registry"
  acr_name   = "acrprodmicrotasker"
  rg_name    = "rg-prod-microtasker"
  location   = "centralindia"
  tags       = local.common_tags
}

module "sql_server" {
  depends_on      = [module.rg]
  source          = "../../modules/azurerm_sql_server"
  sql_server_name = "sql-prod-microtasker"
  rg_name         = "rg-prod-microtasker"
  location        = "centralindia"
  admin_username  = "prodopsadmin"
  admin_password  = "P@ssw01rd@123"
  tags            = local.common_tags
}

module "sql_db" {
  depends_on  = [module.sql_server]
  source      = "../../modules/azurerm_sql_database"
  sql_db_name = "sqldb-prod-microtasker"
  server_id   = module.sql_server.server_id
  max_size_gb = "2"
  tags        = local.common_tags
}

module "aks" {
  depends_on = [module.rg]
  source     = "../../modules/azurerm_kubernetes_cluster"
  aks_name   = "aks-prod-microtasker"
  location   = "centralindia"
  rg_name    = "rg-prod-microtasker"
  dns_prefix = "aks-prod-microtasker"
  tags       = local.common_tags
}



module "pip" {
  source   = "../../modules/azurerm_public_ip"
  pip_name = "pip-prod-microtasker"
  rg_name  = "rg-prod-microtasker"
  location = "centralindia"
  sku      = "Standard"
  tags     = local.common_tags
}
