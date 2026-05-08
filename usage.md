# Usage Guide

Follow these steps to deploy and configure the AKM Technical Challenge environment.

## Prerequisites

- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) configured and authenticated (`gcloud auth application-default login`).
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

1. Ensure `inventory.ini` is updated with the Public IP of Machine A (as `ansible_host` for `machine_a` and in the `ProxyCommand`).
2. Ensure the private key (`akm-key.pem`) has correct permissions:
   ```bash
   chmod 400 akm-key.pem
   ```
3. Run the Ansible playbook (the local `ansible.cfg` automatically handles host key checking):
   ```bash
   ansible-playbook -i inventory.ini site.yml
   ```
   *Note: The playbook will automatically fetch Machine A's public key to your local directory to configure Machines B and C.*

## Step 3: Verification

- Access `http://<Machine_A_Public_IP>/test.html` to see the round-robin load balancing.
- Access any other path to verify the redirect to Google.
