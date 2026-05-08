output "machine_a_public_ip" {
  value = google_compute_instance.machine_a.network_interface.0.access_config.0.nat_ip
}
output "machine_a_private_ip" {
  value = google_compute_instance.machine_a.network_interface.0.network_ip
}
output "machine_b_private_ip" {
  value = google_compute_instance.machine_b.network_interface.0.network_ip
}
output "machine_c_private_ip" {
  value = google_compute_instance.machine_c.network_interface.0.network_ip
}
