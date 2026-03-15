"""
ITCMS - Appian REST API Base Client
Author  : Raja (Rajasegaran C) - Cloud & DevOps Engineer
Purpose : Reusable base client for all Appian API operations
"""

import os
import logging
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)


class AppianClient:
    """
    Base HTTP client for Appian REST API.
    Handles authentication, retries, timeouts, and error handling.
    """

    def __init__(self, base_url: str = None, api_key: str = None):
        self.base_url = (base_url or os.environ.get('APPIAN_BASE_URL', '')).rstrip('/')
        self.api_key  = api_key  or os.environ.get('APPIAN_API_KEY', '')

        if not self.base_url:
            raise ValueError("APPIAN_BASE_URL is required")
        if not self.api_key:
            raise ValueError("APPIAN_API_KEY is required")

        self.session = self._build_session()
        logger.info(f"AppianClient initialized → {self.base_url}")

    def _build_session(self) -> requests.Session:
        """Build session with retry logic and auth headers."""
        session = requests.Session()

        retry_strategy = Retry(
            total=3,
            backoff_factor=2,
            status_forcelist=[429, 500, 502, 503, 504]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("https://", adapter)
        session.mount("http://",  adapter)

        session.headers.update({
            'Appian-API-Key': self.api_key,
            'Content-Type':   'application/json',
            'Accept':         'application/json'
        })
        return session

    def get(self, endpoint: str, **kwargs) -> requests.Response:
        url = f"{self.base_url}{endpoint}"
        logger.info(f"GET  → {url}")
        response = self.session.get(url, timeout=30, **kwargs)
        self._handle_response(response)
        return response

    def post(self, endpoint: str, **kwargs) -> requests.Response:
        url = f"{self.base_url}{endpoint}"
        logger.info(f"POST → {url}")
        response = self.session.post(url, timeout=120, **kwargs)
        self._handle_response(response)
        return response

    def _handle_response(self, response: requests.Response):
        logger.info(f"Response: HTTP {response.status_code}")
        if response.status_code >= 400:
            logger.error(f"API Error {response.status_code}: {response.text[:200]}")
            response.raise_for_status()

    def health_check(self) -> bool:
        """Verify Appian environment is reachable."""
        try:
            response = self.get('/suite/rest/a/applications/latest/app/health')
            return response.status_code == 200
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return False
