# ITCMS Deployment Runbook
## Author: Raja
## Last Updated: March 2026

## Pre-Deployment Checklist
- [ ] Change Request approved in Appian ITCMS
- [ ] CAB sign-off received
- [ ] Rollback plan documented
- [ ] Maintenance window communicated

## Deployment Steps
1. Pipeline triggered automatically via Appian webhook
2. Monitor Azure DevOps pipeline execution
3. Validate deployment in target environment
4. Update Change Request status to IMPLEMENTED

## Rollback Procedure
1. Reject the deployment in Azure DevOps
2. Update Change Request status to ROLLBACK
3. Re-import previous package version
