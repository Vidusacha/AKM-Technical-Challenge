# AKM Technical Challenge

Infrastructure automation project to provision and configure a load-balanced web server environment on GCP using Terraform and Ansible.

## Architecture

The environment consists of three Compute Engine instances (`e2-micro`) within a dedicated VPC in `us-central1`:

- **Machine A**: Entry point acting as a Load Balancer (HAProxy). It has a Public IP and routes traffic to the backend servers.
- **Machine B & C**: Backend web servers (Nginx) listening on port 8080. They reside in a private network segment, reaching the internet via Cloud NAT for updates.

## Features

- **Automated Infrastructure**: VPC, Subnets, Firewalls, and Compute instances managed by Terraform.
- **Secure Networking**: Internal traffic strictly controlled via GCP Firewall rules and Cloud NAT.
- **Passwordless SSH**: Machine A is configured to manage backend servers via SSH keys.
- **Load Balancing**: HAProxy on Machine A provides round-robin distribution for `/test.html`.
- **Failover/Redirect**: Any non-matching requests are redirected to Google.

## Project Structure

- `main.tf`: Terraform configuration for GCP resources.
- `outputs.tf`: Infrastructure outputs (IP addresses).
- `roadmap.md`: Project status and implementation tracking.
- `site.yml`: Unified Ansible playbook for security and service configuration.
- `inventory.ini`: Ansible inventory file defining host groups and connection variables.
- `ansible.cfg`: Ansible configuration for optimal execution (silencing warnings and key checking).

## Status

**Project Complete**: All phases of infrastructure provisioning, configuration management, and functional verification have been successfully executed and documented.
