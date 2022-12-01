resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
}
# Create VPC connector
# ============================================================================
resource "google_vpc_access_connector" "connector" {
  name          = "connector"
  ip_cidr_range = "10.8.0.0/28"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}
