"""Local server for the Kinh Mạch Đồ (Meridian Map) editor.

Usage (from the repo root):
  python -I tools/design/meridian_rework/editor/serve.py [--port 8765] [--no-browser]

Opens http://127.0.0.1:<port>/ in your browser. Standard library only; listens on 127.0.0.1 only.
The editor reads and writes graph versions in design/meridian-map/versions/ (see ../versions.py):
  GET  /api/versions            every version, newest first
  GET  /api/versions/<name>     one version (header X-Mtime: its file time, for the save check)
  PUT  /api/versions/<name>     overwrite that EXISTING version; refused (409) if the file changed since X-Base-Mtime
  POST /api/versions/<name>     create a NEW version; refused (409) if the name is taken
  GET  /api/catalogue           modifiers, stats and effects read fresh from the GDDs (export_catalogue.build)
Stop it with Ctrl+C.
"""
import http.server
import json
import os
import socket
import sys
import threading
import webbrowser

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import export_catalogue  # noqa: E402
import versions  # noqa: E402

EDITOR = os.path.join(HERE, "editor.html")
LOCK = threading.Lock()


class Handler(http.server.BaseHTTPRequestHandler):
    server_version = "KMDEditor/1"

    def log_message(self, fmt, *args):
        if "/api/versions/" in (args[0] if args else "") and not str(args[0]).startswith("GET"):
            sys.stderr.write("  " + (fmt % args) + "\n")

    def _send(self, code, body, ctype="application/json; charset=utf-8", headers=None):
        if isinstance(body, (dict, list)):
            body = json.dumps(body, ensure_ascii=False).encode("utf-8")
        elif isinstance(body, str):
            body = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        for k, v in (headers or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def _name(self):
        name = self.path.split("?")[0][len("/api/versions/"):]
        from urllib.parse import unquote
        name = unquote(name)
        return name if versions.valid_name(name) else None

    def _body(self):
        """Read the whole request body first, even for a request about to be refused: answering before the upload
        is read makes the browser see a reset connection instead of the answer."""
        n = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(n)
        try:
            return json.loads(raw.decode("utf-8"))
        except ValueError:
            return None

    def _local_only(self):
        # refuse pages from other origins (another site in the browser cannot write the repo through this server)
        origin = self.headers.get("Origin")
        host = self.headers.get("Host", "")
        if origin and origin.split("//", 1)[-1] != host:
            self._send(403, {"error": "cross-origin request refused"})
            return False
        return True

    def _host_ok(self):
        # only answer to our own address (a page on another site cannot reach this server by renaming itself)
        host = self.headers.get("Host", "").rsplit(":", 1)[0]
        if host not in ("127.0.0.1", "localhost"):
            self._send(403, {"error": "unexpected host"})
            return False
        return True

    def do_GET(self):
        if not self._host_ok():
            return
        path = self.path.split("?")[0]
        if path in ("/", "/index.html", "/editor.html"):
            with open(EDITOR, "rb") as f:
                return self._send(200, f.read(), "text/html; charset=utf-8")
        if path == "/api/versions":
            return self._send(200, versions.listing())
        if path == "/api/catalogue":
            try:
                return self._send(200, export_catalogue.build())
            except Exception as e:  # a GDD mid-edit should not break the editor
                return self._send(200, {"modifiers": [], "stats": [], "effects": [], "error": str(e)})
        if path.startswith("/api/versions/"):
            name = self._name()
            if not name or not os.path.exists(versions.path_of(name)):
                return self._send(404, {"error": "no such version"})
            p = versions.path_of(name)
            with open(p, "rb") as f:
                return self._send(200, f.read(), headers={"X-Mtime": repr(os.stat(p).st_mtime)})
        self._send(404, {"error": "not found"})

    def do_PUT(self):
        data = self._body()
        if not self._host_ok() or not self._local_only():
            return
        if not isinstance(data, dict) or not isinstance(data.get("nodes"), list):
            return self._send(400, {"error": "not a graph version"})
        name = self._name()
        if not name:
            return self._send(400, {"error": "bad version name"})
        with LOCK:
            p = versions.path_of(name)
            if not os.path.exists(p):
                return self._send(404, {"error": "no such version; use Save as new version"})
            base = self.headers.get("X-Base-Mtime")
            if base and self.headers.get("X-Force") != "1" and abs(float(base) - os.stat(p).st_mtime) > 1e-6:
                return self._send(409, {"error": "changed on disk since you opened it", "mtime": os.stat(p).st_mtime})
            versions.overwrite(name, data)
            return self._send(200, {"name": name, "mtime": os.stat(p).st_mtime})

    def do_POST(self):
        data = self._body()
        if not self._host_ok() or not self._local_only():
            return
        if not isinstance(data, dict) or not isinstance(data.get("nodes"), list):
            return self._send(400, {"error": "not a graph version"})
        name = self._name()
        if not name:
            return self._send(400, {"error": "bad version name"})
        with LOCK:
            if os.path.exists(versions.path_of(name)):
                return self._send(409, {"error": "a version with that name exists", "suggest": versions.free_name(name)})
            meta = data.get("meta") or {}
            got = versions.write_new(data, name, source="editor", parent=meta.get("parent"), note=meta.get("note", ""))
            return self._send(200, {"name": got, "mtime": os.stat(versions.path_of(got)).st_mtime, "meta": versions.read(got)["meta"]})


def free_port(start):
    for p in range(start, start + 50):
        with socket.socket() as s:
            try:
                s.bind(("127.0.0.1", p))
                return p
            except OSError:
                continue
    raise SystemExit("no free port")


def main():
    port = free_port(int(sys.argv[sys.argv.index("--port") + 1]) if "--port" in sys.argv else 8765)
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler)
    url = f"http://127.0.0.1:{port}/"
    print(f"Meridian Map editor: {url}  (versions in {versions.VERSIONS_DIR}; Ctrl+C to stop)")
    if "--no-browser" not in sys.argv:
        threading.Timer(0.4, lambda: webbrowser.open(url)).start()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
