# 🔄 IT Change Management System (ITCMS)
### Appian BPM + Azure DevOps CI/CD + AWS Infrastructure

[![Azure DevOps](https://img.shields.io/badge/CI/CD-Azure%20DevOps-blue)](https://dev.azure.com)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-purple)](https://terraform.io)
[![AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com)
[![Appian](https://img.shields.io/badge/BPM-Appian-red)](https://appian.com)

## 📋 Project Overview
Enterprise-grade IT Change Management BPM application built on Appian,
with full CI/CD automation using Azure DevOps pipelines and AWS cloud
infrastructure provisioned via Terraform.

## 🏗️ Architecture
- **BPM Application**: Appian (IT Change Advisory Board workflow)
- **CI/CD**: Azure DevOps Pipelines
- **Cloud**: AWS (EC2, RDS, S3, VPC) — Region: ap-south-1 (Mumbai)
- **IaC**: Terraform
- **Automation**: Python (Appian REST API)
- **Monitoring**: AWS CloudWatch + Grafana
- **Secrets**: AWS Secrets Manager

## 🔄 Workflow
Requestor → Raise Change → CAB Review → Approve/Reject
↓ (Approved)
Azure DevOps Pipeline Triggered (via Appian webhook)
↓
DEV → TEST → PROD (with approval gates)

## 📁 Repository Structure
| Folder | Contents |
|--------|----------|
| `appian/` | Process models, interfaces, integrations, records |
| `terraform/` | AWS infrastructure as code (modules + environments) |
| `azure-devops/` | CI/CD pipeline YAML and templates |
| `python-scripts/` | Appian REST API automation scripts |
| `monitoring/` | Grafana dashboards, CloudWatch alarms |
| `docs/` | Architecture diagrams, runbooks, screenshots |

## 🚀 Setup Instructions
See [docs/runbooks/deployment-runbook.md](docs/runbooks/deployment-runbook.md)

## 👤 Author
**Raja** — Cloud & DevOps Engineer
- 18+ years enterprise IT infrastructure experience
- Clients: Wells Fargo, Deutsche Bank, Munichre, SAP, T-Mobile
- Skills: AWS, Azure, GCP, Terraform, Kubernetes, Appian, Python

