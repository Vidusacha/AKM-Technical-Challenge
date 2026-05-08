# Usage Guide

Follow these steps to deploy and configure the AKM Technical Challenge environment.

## Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials.
- [Terraform](https://www.terraform.io/downloads) installed locally.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/index.html) installed on your control machine.

## Step 1: Provision Infrastructure

1. Navigate to the project root.
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the changes:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```
5. Note the outputs (Public IP of Machine A and Private IPs of B & C).

## Step 2: Configuration Management

1. Generate or update the Ansible inventory with the IPs from Step 1.
2. Ensure the private key (`akm-key.pem`) has correct permissions:
   ```bash
   chmod 400 akm-key.pem
   ```
3. Run the Ansible playbook:
   ```bash
   ansible-playbook -i inventory.ini site.yml
   ```

## Step 3: Verification

- Access `http://<Machine_A_Public_IP>/test.html` to see the round-robin load balancing.
- Access any other path to verify the redirect to Google.
