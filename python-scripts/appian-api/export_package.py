"""
ITCMS - Appian Package Export Script
Author  : Raja (Rajasegaran C) - Cloud & DevOps Engineer
Called by: Azure DevOps Pipeline - Stage 2 (Export)
Usage   : python export_package.py --app-name "ITCMS" \
                                   --package-name "ITCMS_Package" \
                                   --output-dir "./packages" \
                                   --build-number "20260315.1"
"""

import os
import sys
import json
import time
import argparse
import logging
from datetime import datetime
from pathlib import Path
from appian_client import AppianClient

logger = logging.getLogger(__name__)


def parse_args():
    parser = argparse.ArgumentParser(description='Export Appian Application Package')
    parser.add_argument('--app-name',     required=True)
    parser.add_argument('--package-name', required=True)
    parser.add_argument('--output-dir',   required=True)
    parser.add_argument('--build-number', required=False, default='local')
    return parser.parse_args()


def get_application_id(client: AppianClient, app_name: str) -> str:
    """Fetch application UUID by name from Appian."""
    logger.info(f"Searching for application: {app_name}")
    response = client.get('/suite/rest/a/applications/latest/app')
    apps = response.json()

    for app in apps.get('applications', []):
        if app.get('name', '').strip().lower() == app_name.strip().lower():
            app_id = app.get('id')
            logger.info(f"Found: {app_name} → ID: {app_id}")
            return app_id

    raise ValueError(f"Application '{app_name}' not found in Appian environment")


def trigger_export(client: AppianClient, app_id: str, package_name: str) -> str:
    """Trigger package export and return export job ID."""
    payload = {
        "name":          package_name,
        "applicationId": app_id,
        "description":   f"Exported by ITCMS CI/CD - {datetime.utcnow().isoformat()}"
    }
    response  = client.post('/suite/rest/a/applications/latest/app/export', json=payload)
    export_id = response.json().get('exportId')
    logger.info(f"Export job started → ID: {export_id}")
    return export_id


def wait_for_export(client: AppianClient, export_id: str, timeout: int = 300) -> str:
    """Poll export status until complete, return download URL."""
    logger.info(f"Polling export status...")
    start = time.time()

    while time.time() - start < timeout:
        response = client.get(f'/suite/rest/a/applications/latest/app/export/{export_id}/status')
        state    = response.json().get('state', 'UNKNOWN')
        logger.info(f"Export state: {state}")

        if state == 'COMPLETED':
            return response.json().get('downloadUrl')
        elif state == 'FAILED':
            raise RuntimeError(f"Export failed: {response.json().get('errorMessage')}")

        time.sleep(10)

    raise TimeoutError(f"Export timed out after {timeout}s")


def download_package(client: AppianClient, download_url: str,
                     output_dir: str, package_name: str, build_number: str) -> str:
    """Download the exported zip to local disk."""
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    filename   = f"{package_name}_{build_number}.zip"
    local_path = os.path.join(output_dir, filename)

    response = client.session.get(download_url, stream=True, timeout=120)
    response.raise_for_status()

    with open(local_path, 'wb') as f:
        for chunk in response.iter_content(chunk_size=8192):
            f.write(chunk)

    size_mb = os.path.getsize(local_path) / (1024 * 1024)
    logger.info(f"Downloaded: {filename} ({size_mb:.2f} MB)")
    return local_path


def save_manifest(output_dir: str, metadata: dict):
    manifest_path = os.path.join(output_dir, 'manifest.json')
    with open(manifest_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    logger.info(f"Manifest saved → {manifest_path}")


def main():
    args   = parse_args()
    client = AppianClient()

    logger.info("=" * 55)
    logger.info("  ITCMS - Appian Package Export")
    logger.info(f"  App     : {args.app_name}")
    logger.info(f"  Package : {args.package_name}")
    logger.info(f"  Build   : {args.build_number}")
    logger.info("=" * 55)

    # Step 1 - Health check
    if not client.health_check():
        logger.error("Appian environment unhealthy! Aborting.")
        sys.exit(1)

    # Step 2 - Get application ID
    app_id = get_application_id(client, args.app_name)

    # Step 3 - Trigger export
    export_id = trigger_export(client, app_id, args.package_name)

    # Step 4 - Wait for completion
    download_url = wait_for_export(client, export_id)

    # Step 5 - Download package
    local_path = download_package(
        client, download_url,
        args.output_dir, args.package_name, args.build_number
    )

    # Save manifest for traceability
    save_manifest(args.output_dir, {
        "app_name":     args.app_name,
        "app_id":       app_id,
        "package_name": args.package_name,
        "build_number": args.build_number,
        "export_id":    export_id,
        "exported_at":  datetime.utcnow().isoformat(),
        "file_path":    local_path
    })

    logger.info(f"✅ Export SUCCESS: {local_path}")
    sys.exit(0)


if __name__ == '__main__':
    main()
