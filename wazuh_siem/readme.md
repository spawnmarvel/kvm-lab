# Wazuh - Open Source XDR. Open Source SIEM

## Table of content

- [azuh---open-source-xdr-open-source-siem)](#wazuh---open-source-xdr-open-source-siem)
- [core-architecture](#core-architecture)
- [key-capabilities](#key-capabilities)

## Wazuh - Open Source XDR. Open Source SIEM

Wazuh is a free, open-source Security Information and Event Management (SIEM) and Extended Detection and Response (XDR) platform used for real-time threat detection, log analysis, and endpoint security.

* https://wazuh.com/


### Core Architecture

• Wazuh Agent: Lightweight software installed on endpoints (Windows, Linux, macOS) to collect security telemetry, monitor file integrity, and scan for vulnerabilities.

• Wazuh Server: Central manager that receives data from agents, runs decoders and detection rules, and manages agent configurations.

• Wazuh Indexer: A distributed search engine (forked from OpenSearch) that stores and indexes security events in near real time.

• Wazuh Dashboard: A web-based user interface for data visualization, threat hunting, and compliance reporting.



### Key Capabilities

• Log Data Analysis: Collects and parses operating system, application, and network device logs.

• File Integrity Monitoring (FIM): Tracks changes in file contents, permissions, ownership, and attributes.

• Vulnerability Detection: Scans software inventories and correlates them with CVE (Common Vulnerabilities and Exposures) databases.

• Security Configuration Assessment (SCA): Checks systems against CIS benchmarks and hardening guides.

• Regulatory Compliance: Out-of-the-box dashboards and reports for standards like PCI DSS, GDPR, HIPAA, and NIST.

• Active Response: Automatically executes countermeasures, such as blocking malicious IP addresses or isolating compromised hosts.

## Install wazuh

https://wazuh.com/install/


https://documentation.wazuh.com/current/installation-guide/index.html

## Single universal agent

https://wazuh.com/install/


Installing the Wazuh agent

The Wazuh agent is a single, lightweight monitoring software. It is a multi-platform component that you can deploy to laptops, desktops, servers, cloud instances, containers, or virtual machines.


https://documentation.wazuh.com/current/installation-guide/index.html