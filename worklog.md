# Documentation / Worklog

## Deviations from Requirements
[cite_start]As per the requirement to provide an explanation for any deviation[cite: 24], please review the following architectural and configuration decisions:

1.  **Deviation: HAProxy Port Configuration (80 vs 443)**
    * [cite_start]**Reason:** The provided diagram indicates that Machine A should use `haproxy-tcp/443`. [cite_start]However, the detailed instructions state that "haproxy should listen on tcp/80"  [cite_start]and require testing via `http://<Machine A>/test.html`. I configured HAProxy to listen on tcp/80 to satisfy the explicit functional requirement and the HTTP testing protocol.
2.  **Deviation: Internal IP Address Numbering**
    * [cite_start]**Reason:** The diagram specifies internal IPs as `192.168.0.1`, `192.168.0.2`, and `192.168.0.3`[cite: 3, 4, 5]. In major cloud providers (like GCP and AWS), the first usable IP addresses in a subnet (e.g., .1) are reserved for the default gateway and internal DNS. Therefore, the instances were provisioned with `192.168.0.10`, `192.168.0.20`, and `192.168.0.30` respectively to maintain the `192.168.0.x` scheme without conflicting with cloud provider reservations.
3.  **Deviation: Outbound Internet Access for Internal Nodes (NAT)**
    * [cite_start]**Reason:** The diagram implies Machines B and C reside in a private subnet without an external IP address [cite: 4, 5][cite_start], while Machine A has an "+ external IP address". [cite_start]To satisfy the requirement to "Download and configure nginx to run on Machines B and C" [cite: 12] without assigning them public IPs, a Cloud NAT router was implemented. This allows outbound internet access for package installation while adhering to the secure, private topology implied by the diagram.
4.  **Deviation: iptables Execution Order**
    * [cite_start]**Reason:** The requirement states to "Block everything except SSH and the services running". The `DROP` policy was applied during the Ansible run, prior to package installation. Package downloads succeed because a stateful rule allowing `ESTABLISHED` and `RELATED` connections was added first, ensuring the machines remain perfectly secure from external ingress at all times without breaking outbound updates.