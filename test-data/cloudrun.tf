# Create Cloud Run Deployment
# ============================================================================
resource "google_cloud_run_service" "cr_service" {
  name     = var.cr_service_name
  location = var.region
  template {
    spec {
      containers {
        image = var.cr_image

        ports {
          name           = "http1"
          container_port = 4242
        }

        env {
          name  = "DATABASE_HOST"
          value = google_sql_database_instance.master.private_ip_address
        }
        env {
          name  = "DATABASE_NAME"
          value = "postgres"
        }
        env {
          name  = "DATABASE_USERNAME"
          value = var.postgres_username
        }
        env {
          name  = "DATABASE_PASSWORD"
          value = var.postgres_password
        }
        env {
          name  = "DATABASE_SSL"
          value = "{\"rejectUnauthorized\": false,\"ca\": \"${replace(google_sql_ssl_cert.client_cert.server_ca_cert, "\n", "\\n")}\",\"cert\": \"${replace(google_sql_ssl_cert.client_cert.cert, "\n", "\\n")}\",\"key\":\"${replace(google_sql_ssl_cert.client_cert.private_key, "\n", "\\n")}\"}"
        }

        resources {
          limits = {
            cpu    = 2
            memory = "512Mi"
          }
        }
      }

      container_concurrency = 80
      timeout_seconds       = 300
      service_account_name  = "${var.service_accounts.myapp.name}@${var.project_id}.iam.gserviceaccount.com"
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = var.cr_min_instances
        "autoscaling.knative.dev/maxScale"        = var.cr_max_instances
        "run.googleapis.com/cpu-throttling"       = var.cr_cpu_throttling
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}