import json
import os
import time
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, HTTPServer
from threading import Lock


SERVICE_NAME = "announcement-app"
HISTOGRAM_BUCKETS = (0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0)
METRICS_LOCK = Lock()
REQUEST_TOTAL = {}
REQUEST_DURATION_SUM = {}
REQUEST_DURATION_COUNT = {}
REQUEST_DURATION_BUCKETS = {}


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


def route_label(path):
    if path in {"/", "/healthz", "/readyz", "/metrics"}:
        return path
    return "other"


def observe_request(method, path, status_code, duration_seconds):
    if path == "/metrics":
        return

    labels = (SERVICE_NAME, str(status_code), route_label(path), method)
    with METRICS_LOCK:
        REQUEST_TOTAL[labels] = REQUEST_TOTAL.get(labels, 0) + 1
        REQUEST_DURATION_SUM[labels] = REQUEST_DURATION_SUM.get(labels, 0.0) + duration_seconds
        REQUEST_DURATION_COUNT[labels] = REQUEST_DURATION_COUNT.get(labels, 0) + 1
        for bucket in HISTOGRAM_BUCKETS:
            if duration_seconds <= bucket:
                bucket_labels = labels + (bucket,)
                REQUEST_DURATION_BUCKETS[bucket_labels] = REQUEST_DURATION_BUCKETS.get(bucket_labels, 0) + 1


def render_metrics():
    lines = [
        "# HELP http_server_requests_total Total HTTP requests.",
        "# TYPE http_server_requests_total counter",
    ]

    with METRICS_LOCK:
        for labels, value in sorted(REQUEST_TOTAL.items()):
            service_name, status_code, route, method = labels
            lines.append(
                'http_server_requests_total{service_name="%s",status_code="%s",route="%s",method="%s"} %d'
                % (service_name, status_code, route, method, value)
            )

        lines.extend(
            [
                "# HELP http_server_request_duration_seconds HTTP request duration in seconds.",
                "# TYPE http_server_request_duration_seconds histogram",
            ]
        )

        for labels, count in sorted(REQUEST_DURATION_COUNT.items()):
            service_name, status_code, route, method = labels
            cumulative = 0
            for bucket in HISTOGRAM_BUCKETS:
                bucket_labels = labels + (bucket,)
                cumulative = REQUEST_DURATION_BUCKETS.get(bucket_labels, cumulative)
                lines.append(
                    'http_server_request_duration_seconds_bucket{service_name="%s",status_code="%s",route="%s",method="%s",le="%s"} %d'
                    % (service_name, status_code, route, method, bucket, cumulative)
                )
            lines.append(
                'http_server_request_duration_seconds_bucket{service_name="%s",status_code="%s",route="%s",method="%s",le="+Inf"} %d'
                % (service_name, status_code, route, method, count)
            )
            lines.append(
                'http_server_request_duration_seconds_sum{service_name="%s",status_code="%s",route="%s",method="%s"} %.6f'
                % (service_name, status_code, route, method, REQUEST_DURATION_SUM.get(labels, 0.0))
            )
            lines.append(
                'http_server_request_duration_seconds_count{service_name="%s",status_code="%s",route="%s",method="%s"} %d'
                % (service_name, status_code, route, method, count)
            )

    return ("\n".join(lines) + "\n").encode("utf-8")


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
        start = time.perf_counter()
        status_code = HTTPStatus.OK

        if self.path == "/healthz":
            status_code = HTTPStatus.OK
            self._write_json(status_code, {"status": "ok"})
            observe_request("GET", self.path, int(status_code), time.perf_counter() - start)
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
            observe_request("GET", self.path, int(status_code), time.perf_counter() - start)
            return

        if self.path == "/":
            status_code = HTTPStatus.OK
            payload = current_settings()
            payload["status"] = "ready" if is_ready() else "not-ready"
            self._write_json(status_code, payload)
            observe_request("GET", self.path, int(status_code), time.perf_counter() - start)
            return

        if self.path == "/metrics":
            body = render_metrics()
            self.send_response(HTTPStatus.OK)
            self.send_header("Content-Type", "text/plain; version=0.0.4")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return

        status_code = HTTPStatus.NOT_FOUND
        self._write_json(status_code, {"error": "not found", "path": self.path})
        observe_request("GET", self.path, int(status_code), time.perf_counter() - start)

    def log_message(self, format, *args):
        return


def main():
    port = int(os.getenv("PORT", "8080"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    server.serve_forever()


if __name__ == "__main__":
    main()
