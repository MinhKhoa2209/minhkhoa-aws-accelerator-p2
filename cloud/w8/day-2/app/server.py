import json
import os
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, HTTPServer


def current_settings():
    return {
        "app_name": os.getenv("APP_NAME", "announcement-app"),
        "owner": os.getenv("APP_OWNER", "unknown"),
        "environment": os.getenv("APP_ENV", "learning"),
        "message": os.getenv("APP_MESSAGE", "hello from kubernetes"),
        "secret_loaded": bool(os.getenv("API_TOKEN")),
    }


def is_ready():
    settings = current_settings()
    return bool(settings["message"]) and settings["secret_loaded"]


class Handler(BaseHTTPRequestHandler):
    server_version = "W8Announcement/0.1"

    def _write_json(self, status_code, payload):
        body = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/healthz":
            self._write_json(HTTPStatus.OK, {"status": "ok"})
            return

        if self.path == "/readyz":
            ready = is_ready()
            status_code = HTTPStatus.OK if ready else HTTPStatus.SERVICE_UNAVAILABLE
            self._write_json(
                status_code,
                {
                    "status": "ready" if ready else "not-ready",
                    "checks": {
                        "message_present": bool(os.getenv("APP_MESSAGE")),
                        "api_token_present": bool(os.getenv("API_TOKEN")),
                    },
                },
            )
            return

        if self.path == "/":
            payload = current_settings()
            payload["status"] = "ready" if is_ready() else "not-ready"
            self._write_json(HTTPStatus.OK, payload)
            return

        self._write_json(HTTPStatus.NOT_FOUND, {"error": "not found", "path": self.path})

    def log_message(self, format, *args):
        return


def main():
    port = int(os.getenv("PORT", "8080"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    server.serve_forever()


if __name__ == "__main__":
    main()
