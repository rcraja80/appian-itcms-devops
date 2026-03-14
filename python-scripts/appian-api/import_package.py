"""
Appian Package Import Script
Calls Appian Deployment REST API to import/deploy application package
Author: Raja
"""
import requests
import os

APPIAN_BASE_URL = os.environ.get("APPIAN_BASE_URL")
APPIAN_API_KEY  = os.environ.get("APPIAN_API_KEY")
TARGET_ENV      = os.environ.get("TARGET_ENV", "dev")

def import_package(package_path: str, environment: str) -> dict:
    # TODO: Implement in Phase 3
    pass

if __name__ == "__main__":
    import_package("./packages/ITCMS_Package.zip", TARGET_ENV)
