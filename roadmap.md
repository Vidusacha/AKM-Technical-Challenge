# roadmap.md

## Phase 1: Cloud Infrastructure Provisioning (Terraform on AWS)
- [x] Configure AWS CLI and authentication credentials locally.
- [x] Create Terraform configuration files (`main.tf`, `outputs.tf`).
- [x] Define an AWS VPC, subnets, and an internet gateway.
- [x] Define 3 EC2 instances (t2.micro using an Ubuntu AMI) as Machine A, B, and C.
- [x] Assign a Public IP to Machine A. Machines B and C will reside in a public subnet for local Ansible access but will use their Private IPs for internal application routing.
- [x] Define AWS Security Groups to allow SSH (tcp/22) from the local IP to all machines, and allow HTTP (tcp/80) to Machine A.
- [ ] Execute `terraform init`, `terraform plan`, and `terraform apply` to provision the infrastructure.
- [ ] Extract the IP addresses from Terraform outputs to populate the Ansible inventory.

## Phase 2: Configuration Management (Ansible)
- [ ] Create an `inventory.ini` file defining Machine A as the load balancer and Machines B and C as web servers.
- [ ] Create a unified playbook (`site.yml`) with the following roles/tasks:
    - [ ] **Security (All Machines):** Configure `iptables`.
        - [ ] Machine A: Allow SSH (tcp/22) and HAProxy (tcp/80). Block all else.
        - [ ] Machines B and C: Allow SSH (tcp/22) and Nginx (tcp/8080). Block all else.
    - [ ] **SSH Requirement:** Generate an SSH key on Machine A and distribute its public key to `~/.ssh/authorized_keys` on Machines B and C for passwordless login.
    - [ ] **Web Servers (Machines B and C):**
        - [ ] Install Nginx.
        - [ ] Configure Nginx to listen on tcp/8080.
        - [ ] Create `/test.html` returning "Hello world from Machine B" (or C).
    - [ ] **Load Balancer (Machine A):**
        - [ ] Install HAProxy.
        - [ ] Configure HAProxy to listen on tcp/80.
        - [ ] Route requests for `/test.html` to Machines B and C using a round-robin algorithm.
        - [ ] Redirect all other requests to `www.google.com`.

## Phase 3: Deployment and Testing
- [ ] Execute the Ansible playbook from the local workstation.
- [ ] Access `http://<Machine A external IP>/test.html` in a web browser.
- [ ] Refresh the page to verify round-robin behavior.
- [ ] Access `http://<Machine A external IP>/random_page` and verify redirection to Google.

## Phase 4: Documentation
- [ ] Commit the Terraform configurations and Ansible playbooks to the Git repository.
- [ ] **Deviation Action 1:** Document the port conflict. The diagram indicates Machine A using `haproxy-tcp/443`, but the text specifies `tcp/80`. Resolution: Configured HAProxy for `tcp/80` as per text instructions.
- [ ] **Deviation Action 2:** Document the IP address conflict. The diagram specifies `192.168.0.1`, `192.168.0.2`, and `192.168.0.3`. Because AWS reserves the first four IP addresses in a subnet, we assigned `192.168.0.10`, `192.168.0.20`, and `192.168.0.30` instead.
