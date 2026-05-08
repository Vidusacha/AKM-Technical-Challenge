# roadmap.md

## Phase 1: Cloud Infrastructure Provisioning (Terraform on GCP)
- [x] Install Terraform on the local workstation.
- [x] Install Google Cloud CLI and authenticate locally (`gcloud init`, `gcloud auth application-default login`).
- [x] Create Terraform configuration files (`main.tf`, `outputs.tf`) using the Google provider.
- [x] Define a GCP VPC network, subnets, and firewall rules.
- [x] Define 3 compute instances (`e2-micro` using Ubuntu Minimal 22.04 LTS) in the `us-central1` region.
- [x] Assign a Public IP to Machine A. Machines B and C reside in the subnet but use internal IPs for routing.
- [x] Execute `terraform init`, `terraform plan`, and `terraform apply` to provision the infrastructure.
- [x] Extract the IP addresses from Terraform outputs to populate the Ansible inventory.
- [x] Implemented Cloud Router and Cloud NAT to allow private instances (B and C) to access the internet for package updates.

## Phase 2: Configuration Management (Ansible)
- [x] Create an `inventory.ini` file defining Machine A as the load balancer and Machines B and C as web servers.
- [x] Create a unified playbook (`site.yml`) with the following roles/tasks:
    - [x] **Security (All Machines):** Configure `iptables`.
        - [x] Machine A: Allow SSH (tcp/22) and HAProxy (tcp/80). Block all else.
        - [x] Machines B and C: Allow SSH (tcp/22) and Nginx (tcp/8080). Block all else.
    - [x] **SSH Requirement:** Generate an SSH key on Machine A and distribute its public key to `~/.ssh/authorized_keys` on Machines B and C for passwordless login.
    - [x] **Web Servers (Machines B and C):**
        - [x] Install Nginx.
        - [x] Configure Nginx to listen on tcp/8080.
        - [x] Create `/test.html` returning "Hello world from Machine B" (or C).
    - [x] **Load Balancer (Machine A):**
        - [x] Install HAProxy.
        - [x] Configure HAProxy to listen on tcp/80.
        - [x] Route requests for `/test.html` to Machines B and C using a round-robin algorithm.
        - [x] Redirect all other requests to `www.google.com`.
- [x] Added `ansible.cfg` to silence deprecation warnings and disable host key checking prompts.

## Phase 3: Deployment and Testing
- [x] Execute the Ansible playbook from the local workstation.
- [x] Access `http://<Machine A external IP>/test.html` in a web browser.
- [x] Refresh the page to verify round-robin behavior.
- [x] Access `http://<Machine A external IP>/random_page` and verify redirection to Google.

## Phase 4: Documentation
- [x] Commit the Terraform configurations and Ansible playbooks to the Git repository.
- [x] **Deviation Action 1 (Port Conflict):** The diagram indicates Machine A using `haproxy-tcp/443`, but the text specifies `tcp/80`. Resolution: Configured HAProxy for `tcp/80` as per text instructions.
- [x] **Deviation Action 2 (IP Addresses):** The diagram specifies `192.168.0.1`, `192.168.0.2`, and `192.168.0.3`. Because cloud providers reserve the first IP address for the default gateway, we assigned `192.168.0.10`, `192.168.0.20`, and `192.168.0.30` instead.
- [x] **Deviation Action 3 (Cloud Provider):** Switched from AWS to GCP to utilize the `e2-micro` Free Tier offering. Placed resources in the `us-central1` region to ensure Free Tier eligibility. Added Cloud NAT to allow private instances to download packages securely.