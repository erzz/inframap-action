# Create Cloud SQL Postgres resources
# ============================================================================
resource "google_sql_database_instance" "master" {
  project          = var.project_id
  region           = var.region
  name             = var.db_name
  database_version = "POSTGRES_13"

  # 1 vCPU, 3840 MB RAM, 100 GB Storage
  settings {
    activation_policy = "ALWAYS"
    availability_type = "REGIONAL"
    disk_size         = 100
    disk_type         = "PD_SSD"
    tier              = "db-custom-1-3840"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled = false
      require_ssl  = true

      private_network = google_compute_network.vpc_network.id
    }
  }
}

# Create Cloud SQL user
# ============================================================================
resource "google_sql_user" "users" {
  project  = var.project_id
  name     = var.postgres_username
  password = var.postgres_password
  instance = google_sql_database_instance.master.name
}

# Create CloudSQL Client Certificates
# ============================================================================
resource "google_sql_ssl_cert" "client_cert" {
  common_name = "feature-flags"
  instance    = google_sql_database_instance.master.name
}