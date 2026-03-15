"""
ITCMS - Appian Environment Health Check
Author : Raja (Rajasegaran C) - Cloud & DevOps Engineer
Usage  : python health_check.py --environment DEV
"""

import sys
import argparse
import logging
from datetime import datetime
from appian_client import AppianClient

logger = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(description='Appian Health Check')
    parser.add_argument('--environment', required=True)
    return parser.parse_args()


def run_checks(client: AppianClient) -> dict:
    results = {}

    # Check 1 - API reachability
    try:
        resp = client.get('/suite/rest/a/applications/latest/app/health')
        results["api_reachable"] = "PASS" if resp.status_code == 200 else "FAIL"
    except Exception as e:
        results["api_reachable"] = f"FAIL: {e}"

    # Check 2 - Authentication valid
    try:
        resp = client.get('/suite/rest/a/applications/latest/app')
        results["authentication"] = "PASS" if resp.status_code == 200 else "FAIL"
    except Exception as e:
        results["authentication"] = f"FAIL: {e}"

    # Check 3 - Application listing
    try:
        resp  = client.get('/suite/rest/a/applications/latest/app')
        count = len(resp.json().get('applications', []))
        results["app_listing"] = f"PASS ({count} apps found)"
    except Exception as e:
        results["app_listing"] = f"FAIL: {e}"

    return results


def main():
    args    = parse_args()
    client  = AppianClient()
    results = run_checks(client)

    logger.info("=" * 50)
    logger.info(f"  Health Check — {args.environment} — {datetime.utcnow().isoformat()}")
    logger.info("=" * 50)

    all_passed = True
    for check, result in results.items():
        icon = "✅" if "PASS" in str(result) else "❌"
        logger.info(f"  {icon} {check:<25} : {result}")
        if "FAIL" in str(result):
            all_passed = False

    logger.info("=" * 50)

    if all_passed:
        logger.info(f"✅ {args.environment} is HEALTHY")
        sys.exit(0)
    else:
        logger.error(f"❌ {args.environment} health check FAILED")
        sys.exit(1)


if __name__ == '__main__':
    main()
