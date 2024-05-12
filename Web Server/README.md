# "Amati Marketing" Web Server


### Client Background

Amati Marketing, a rapidly growing digital marketing agency, is looking to overhaul their existing website to support their expanding portfolio and customer base. They require a highly resilient and scalable website that can handle significant traffic fluctuations and provide robust data management capabilities.

### Project Overview

We have been contracted to develop a new state-of-the-art website for Amati Marketing. The website must be capable of independent scalability, ensuring that varying components can be scaled without affecting the overall system performance.

### Technical Specifications

- Web Hosting Service: Amazon Web Services (AWS)
- Compute: Amazon EC2 (Elastic Compute Cloud)
    - Multiple EC2 instances will be used to run the website's applications and services, ensuring robust compute capability.
- Database: Amazon RDS (Relational Database Service)
    - Utilize RDS for database management to handle all backend data storage and retrieval with high availability and automatic failover mechanisms.
- Storage: Amazon EFS (Elastic File System)
    - EFS will be implemented to provide a scalable file storage system for the web application, allowing files to be shared across multiple instances.
- Load Balancing: AWS Elastic Load Balancing (ELB)
    - Implement ELB to distribute incoming application traffic across multiple EC2 instances, enhancing fault tolerance and performance.
- DNS Management: AWS Route 53
    - Route 53 will be used for DNS management, directing users to the most appropriate instance and ensuring efficient traffic management.
- Decoupling & Independent Scalability:
    - Services and resources will be decoupled using AWS service integrations, ensuring components such as computing and database services can be scaled independently based on demand.

### Expected Outcomes

- Enhanced user experience due to reduced load times and improved website responsiveness.
- Increased uptime and availability, ensuring that the website is always accessible to users.
- Scalability to handle peak loads during high traffic periods without compromising on performance.

By leveraging AWS's robust cloud infrastructure and services, we will deliver a resilient, scalable, and high-performance website that aligns with the dynamic needs of Amati Marketing.