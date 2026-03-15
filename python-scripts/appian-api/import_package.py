"""
ITCMS - Appian Package Import Script
Author  : Raja (Rajasegaran C) - Cloud & DevOps Engineer
Called by: Azure DevOps Pipeline - Stage 3/4/5 (Deploy)
Usage   : python import_package.py --package-dir "./packages" \
                                   --environment "DEV" \
                                   --build-number "20260315.1"
"""

import os
import sys
import json
import time
import argparse
import logging
from pathlib import Path
from datetime import datetime
from appian_client import AppianClient

logger = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(description='Import Appian Application Package')
    parser.add_argument('--package-dir',  required=True)
    parser.add_argument('--environment',  required=True)
    parser.add_argument('--build-number', required=False, default='local')
    parser.add_argument('--change-id',    required=False, default='N/A')
    return parser.parse_args()


def find_package_file(package_dir: str) -> str:
    """Find the .zip package file in the directory."""
    zip_files = list(Path(package_dir).glob("*.zip"))
    if not zip_files:
        raise FileNotFoundError(f"No .zip package found in {package_dir}")
    latest = max(zip_files, key=os.path.getmtime)
    logger.info(f"Package found: {latest}")
    return str(latest)


def load_manifest(package_dir: str) -> dict:
    manifest_path = os.path.join(package_dir, 'manifest.json')
    if os.path.exists(manifest_path):
        with open(manifest_path) as f:
            return json.load(f)
    return {}


def upload_and_import(client: AppianClient, package_path: str) -> str:
    """Upload package and trigger import job."""
    logger.info(f"Uploading: {package_path}")

    with open(package_path, 'rb') as pkg:
        response = client.session.post(
            f"{client.base_url}/suite/rest/a/applications/latest/app/import",
            files={'file': (os.path.basename(package_path), pkg, 'application/zip')},
            headers={'Appian-API-Key': client.api_key},
            timeout=300
        )
    response.raise_for_status()
    import_id = response.json().get('importId')
    logger.info(f"Import job started → ID: {import_id}")
    return import_id


def wait_for_import(client: AppianClient, import_id: str, timeout: int = 600) -> bool:
    """Poll import status until complete."""
    logger.info("Polling import status...")
    start = time.time()

    while time.time() - start < timeout:
        response = client.get(
            f'/suite/rest/a/applications/latest/app/import/{import_id}/status'
        )
        state = response.json().get('state', 'UNKNOWN')
        logger.info(f"Import state: {state}")

        if state == 'COMPLETED':
            logger.info("✅ Import completed successfully")
            return True
        elif state == 'COMPLETED_WITH_WARNINGS':
            for w in response.json().get('warnings', []):
                logger.warning(f"⚠️  {w}")
            return True
        elif state == 'FAILED':
            for e in response.json().get('errors', []):
                logger.error(f"❌ {e}")
            raise RuntimeError(f"Import FAILED: {response.json().get('errorMessage')}")

        time.sleep(15)

    raise TimeoutError(f"Import timed out after {timeout}s")


def main():
    args = parse_args()

    logger.info("=" * 55)
    logger.info("  ITCMS - Appian Package Import")
    logger.info(f"  Environment : {args.environment}")
    logger.info(f"  Build       : {args.build_number}")
    logger.info(f"  Change ID   : {args.change_id}")
    logger.info("=" * 55)

    # PROD safety gate — Change ID mandatory
    if args.environment.upper() == 'PROD' and args.change_id == 'N/A':
        logger.error("❌ PRODUCTION deployment requires a Change Request ID!")
        logger.error("   Pass --change-id CHG-XXXX parameter")
        sys.exit(1)

    client = AppianClient()

    # Step 1 - Pre-import health check
    if not client.health_check():
        logger.error("Appian environment not reachable! Aborting.")
        sys.exit(1)
    logger.info("✅ Pre-import health check passed")

    # Step 2 - Find package
    package_path = find_package_file(args.package_dir)
    manifest     = load_manifest(args.package_dir)
    if manifest:
        logger.info(f"Manifest: exported at {manifest.get('exported_at', 'unknown')}")

    # Step 3 - Upload and import
    import_id = upload_and_import(client, package_path)

    # Step 4 - Wait for import
    wait_for_import(client, import_id)

    # Step 5 - Post-import health check
    healthy = client.health_check()
    logger.info("✅ Post-import validation PASSED" if healthy else "⚠️  Post-import check WARN")

    logger.info("=" * 55)
    logger.info(f"✅ IMPORT SUCCESS | {args.environment} | Build {args.build_number}")
    logger.info("=" * 55)
    sys.exit(0)


if __name__ == '__main__':
    main()
