from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os

ROOT = Path("/srv/proxmox")

class PXEHandler(SimpleHTTPRequestHandler):
    def translate_path(self, path):
        # Serve files relative to /srv/proxmox
        path = path.split("?", 1)[0].split("#", 1)[0]
        relative = path.lstrip("/")
        return str(ROOT / relative)

    def do_POST(self):
        # Proxmox sends system information in the POST body.
        content_length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(content_length)

        print(f"POST {self.path}")
        print(body.decode("utf-8", errors="replace"))

        file_path = Path(self.translate_path(self.path))

        if not file_path.is_file():
            self.send_error(404, "Answer file not found")
            return

        data = file_path.read_bytes()

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()

        self.wfile.write(data)


if __name__ == "__main__":
    os.chdir(ROOT)

    server = ThreadingHTTPServer(("0.0.0.0", 8002), PXEHandler)

    print("PXE HTTP server listening on port 8002")
    server.serve_forever()