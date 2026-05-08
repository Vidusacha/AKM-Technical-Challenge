# AKM Technical Challenge

Infrastructure automation project to provision and configure a load-balanced web server environment on AWS using Terraform and Ansible.

## Architecture

The environment consists of three EC2 instances (Ubuntu 22.04) within a dedicated VPC:

- **Machine A**: Entry point acting as a Load Balancer (HAProxy). It has a Public IP and routes traffic to the backend servers.
- **Machine B & C**: Backend web servers (Nginx) listening on port 8080. They are accessible internally from Machine A.

## Features

- **Automated Infrastructure**: VPC, Subnets, Security Groups, and EC2 instances managed by Terraform.
- **Secure Networking**: Internal traffic strictly controlled via Security Groups.
- **Passwordless SSH**: Machine A is configured to manage backend servers via SSH keys.
- **Load Balancing**: HAProxy on Machine A provides round-robin distribution for `/test.html`.
- **Failover/Redirect**: Any non-matching requests are redirected to Google.

## Project Structure

- `main.tf`: Terraform configuration for AWS resources.
- `outputs.tf`: Infrastructure outputs (IP addresses).
- `roadmap.md`: Project status and implementation tracking.
- `ansible/`: (Upcoming) Configuration management playbooks.
