"""
Appian Package Export Script
Calls Appian Deployment REST API to export application package
Author: Raja
"""
import requests
import os
import json

APPIAN_BASE_URL = os.environ.get("APPIAN_BASE_URL")
APPIAN_API_KEY  = os.environ.get("APPIAN_API_KEY")

def export_package(package_name: str) -> dict:
    # TODO: Implement in Phase 3
    pass

if __name__ == "__main__":
    export_package("ITCMS_Package")
