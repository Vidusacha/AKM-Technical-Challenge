terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "ev4petprojects"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# 1. Generate SSH Key locally to use with Ansible later
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.pk.private_key_pem
  filename        = "${path.module}/akm-key.pem"
  file_permission = "0400"
}

# 2. Networking (VPC and Subnet)
resource "google_compute_network" "vpc" {
  name                    = "akm-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "akm-subnet"
  ip_cidr_range = "192.168.0.0/24"
  network       = google_compute_network.vpc.id
}

# 3. Firewalls
resource "google_compute_firewall" "external" {
  name    = "allow-external"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public-web"]
}

resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

  source_ranges = ["192.168.0.0/24"]
  target_tags   = ["internal-web"]
}

# 4. Instances (e2-micro with Ubuntu Minimal)
resource "google_compute_instance" "machine_a" {
  name         = "machine-a"
  machine_type = "e2-micro"
  tags         = ["public-web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    network_ip = "192.168.0.10"
    
    access_config {
      # Assigns Public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.pk.public_key_openssh}"
  }
}

resource "google_compute_instance" "machine_b" {
  name         = "machine-b"
  machine_type = "e2-micro"
  tags         = ["internal-web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    network_ip = "192.168.0.20"
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.pk.public_key_openssh}"
  }
}

resource "google_compute_instance" "machine_c" {
  name         = "machine-c"
  machine_type = "e2-micro"
  tags         = ["internal-web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    network_ip = "192.168.0.30"
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.pk.public_key_openssh}"
  }
}

# 5. Cloud Router and NAT for private internet access (Machines B and C)
resource "google_compute_router" "router" {
  name    = "akm-router"
  network = google_compute_network.vpc.id
  region  = "us-central1"
}

resource "google_compute_router_nat" "nat" {
  name                               = "akm-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
