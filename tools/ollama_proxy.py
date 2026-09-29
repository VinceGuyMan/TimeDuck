#!/usr/bin/env python3
"""
TimeDuck Ollama / OpenAI-Compatible Auto-Splitter Proxy (v1.8.1)
Zero-dependency proxy that transparently forwards requests to Ollama (11434) or LM Studio (1234),
automatically signaling TimeDuck when prompts start, when first tokens stream back (TTFT),
and when responses complete.

Usage:
    python3 tools/ollama_proxy.py [--port 11435] [--target 11434] [--timeduck-port 1834]
"""

import sys
import json
import argparse
from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.request
import urllib.error

TIMEDUCK_URL = "http://127.0.0.1:1834/api"
TARGET_HOST = "127.0.0.1"
TARGET_PORT = 11434

def notify_timeduck(action, label=None):
    try:
        url = f"{TIMEDUCK_URL}/{action}"
        if label:
            url += f"?label={urllib.parse.quote(label)}"
        req = urllib.request.Request(url, method="POST")
        with urllib.request.urlopen(req, timeout=0.5) as resp:
            pass
    except Exception:
        # TimeDuck may be closed or in different mode; non-blocking
        pass

class ProxyHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length) if content_length > 0 else b""

        # Extract model or prompt if JSON
        prompt_label = "AI Prompt"
        try:
            payload = json.loads(body.decode("utf-8"))
            model = payload.get("model", "LLM")
            prompt_label = f"{model}"
        except Exception:
            pass

        # 1. Trigger TimeDuck Start
        notify_timeduck("start", prompt_label)

        # Forward request to local Ollama / target
        target_url = f"http://{TARGET_HOST}:{TARGET_PORT}{self.path}"
        req = urllib.request.Request(
            target_url,
            data=body,
            headers={k: v for k, v in self.headers.items() if k.lower() != "host"},
            method="POST"
        )

        try:
            with urllib.request.urlopen(req) as upstream:
                self.send_response(upstream.status)
                for header, val in upstream.getheaders():
                    self.send_header(header, val)
                self.end_headers()

                # Stream response chunks back to client
                first_chunk = True
                while True:
                    chunk = upstream.read(1024)
                    if not chunk:
                        break
                    if first_chunk:
                        # 2. Trigger TimeDuck Split for TTFT / Thinking
                        notify_timeduck("lap", "TTFT / First Token")
                        first_chunk = False
                    self.wfile.write(chunk)
                    self.wfile.flush()

                # 3. Trigger TimeDuck Complete
                notify_timeduck("stop", f"{prompt_label} Done")

        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
            notify_timeduck("stop", "Error")
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(str(e).encode())
            notify_timeduck("stop", "Error")

    def do_GET(self):
        # Forward health checks and model listings (e.g. /api/tags, /v1/models)
        target_url = f"http://{TARGET_HOST}:{TARGET_PORT}{self.path}"
        req = urllib.request.Request(target_url, headers=dict(self.headers), method="GET")
        try:
            with urllib.request.urlopen(req) as upstream:
                self.send_response(upstream.status)
                for header, val in upstream.getheaders():
                    self.send_header(header, val)
                self.end_headers()
                self.wfile.write(upstream.read())
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(str(e).encode())

    def log_message(self, format, *args):
        # Suppress verbose standard HTTP server logging
        return

def main():
    global TARGET_HOST, TARGET_PORT, TIMEDUCK_URL
    parser = argparse.ArgumentParser(description="TimeDuck AI LiveSplit Proxy")
    parser.add_argument("--port", type=int, default=11435, help="Proxy port to listen on (default: 11435)")
    parser.add_argument("--target-port", type=int, default=11434, help="Upstream Ollama / LLM port (default: 11434)")
    parser.add_argument("--timeduck-port", type=int, default=1834, help="TimeDuck loopback port (default: 1834)")
    args = parser.parse_args()

    TARGET_PORT = args.target_port
    TIMEDUCK_URL = f"http://127.0.0.1:{args.timeduck_port}/api"

    server = HTTPServer(("127.0.0.1", args.port), ProxyHandler)
    print(f"🦆 TimeDuck AI Auto-Splitter Proxy running on http://127.0.0.1:{args.port}")
    print(f"   Forwarding $\\rightarrow$ http://127.0.0.1:{TARGET_PORT}")
    print(f"   Signaling  $\\rightarrow$ {TIMEDUCK_URL}")
    print("   Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nProxy stopped.")

if __name__ == "__main__":
    main()
