#!/bin/bash
# captions-server.sh — tiny HTTP server for OBS browser sources.
#
# OBS browser sources can't read local files reliably (CORS for fetch);
# this is the bridge.
#
# Endpoints:
#   GET /                  → live-captions.html (legacy default)
#   GET /latest            → last whisper transcript line as JSON
#   GET /hotkey-legend     → hotkey-legend.html
#   GET /hotkeys.json      → the SSOT JSON file (edits propagate live)
#   GET /lower-third       → lower-third.html
#   GET /brand.json        → brand SSOT JSON

PORT=8765
TRANSCRIPTS="$HOME/voice/logs/transcripts.jsonl"
BS_DIR="$HOME/stream/obs/browser-sources"
DATA_DIR="$HOME/stream/data"

cd "$BS_DIR" || exit 1

python3 - "$PORT" "$TRANSCRIPTS" "$BS_DIR" "$DATA_DIR" <<'PYEOF'
import sys, json, os
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = int(sys.argv[1])
TRANSCRIPTS = sys.argv[2]
BS_DIR = sys.argv[3]
DATA_DIR = sys.argv[4]

# Endpoint → (relative file, content-type)
ROUTES = {
    '/':              (os.path.join(BS_DIR, 'live-captions.html'), 'text/html'),
    '/hotkey-legend': (os.path.join(BS_DIR, 'hotkey-legend.html'), 'text/html'),
    '/lower-third':   (os.path.join(BS_DIR, 'lower-third.html'),   'text/html'),
    '/notes':         (os.path.join(BS_DIR, 'notes.html'),         'text/html'),
    '/hotkeys.json':  (os.path.join(DATA_DIR, 'hotkeys.json'),     'application/json'),
    '/brand.json':    (os.path.join(DATA_DIR, 'brand.json'),       'application/json'),
    '/cockpit-mech':       (os.path.join(BS_DIR, 'cockpit-mech-portrait.html'), 'text/html'),
    '/cockpit-state.json': (os.path.join(DATA_DIR, 'cockpit-state.json'),       'application/json'),
    '/cockpit-fx':         (os.path.join(BS_DIR, 'cockpit-fx.html'),            'text/html'),
    '/cockpit-test':       (os.path.join(BS_DIR, 'cockpit-test.html'),          'text/html'),
    '/cockpit-image-close':(os.path.join(os.path.expanduser('~'), 'stream/assets/cockpit/close.jpg'), 'image/jpeg'),
    '/cockpit-image-wide': (os.path.join(os.path.expanduser('~'), 'stream/assets/cockpit/wide.jpg'),  'image/jpeg'),
}

# Legacy /cockpit-image route — defaults to close.jpg, overridable via env
COCKPIT_IMAGE = os.environ.get('COCKPIT_IMAGE', os.path.join(os.path.expanduser('~'), 'stream/assets/cockpit/close.jpg'))

class CaptionHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):  # silence access log noise
        pass

    def _send_headers(self, code, ctype):
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()

    def do_GET(self):
        path = self.path.split('?')[0]  # strip query string

        # /cockpit-image — serves the cockpit background image (configurable)
        if path == '/cockpit-image':
            try:
                ext = os.path.splitext(COCKPIT_IMAGE)[1].lower()
                ctype = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png'}.get(ext, 'image/jpeg')
                with open(COCKPIT_IMAGE, 'rb') as f:
                    body = f.read()
                self._send_headers(200, ctype)
                self.wfile.write(body)
                return
            except FileNotFoundError:
                self.send_error(404, f'Cockpit image not found: {COCKPIT_IMAGE}')
                return

        # /latest endpoint — special: tails the transcripts file
        if path == '/latest':
            self._send_headers(200, 'application/json')
            try:
                with open(TRANSCRIPTS, 'rb') as f:
                    f.seek(0, 2)
                    size = f.tell()
                    chunk = min(size, 4096)
                    f.seek(-chunk, 2)
                    data = f.read().decode('utf-8', errors='ignore')
                    lines = [l for l in data.splitlines() if l.strip()]
                    if lines:
                        last = json.loads(lines[-1])
                        self.wfile.write(json.dumps(last).encode())
                        return
            except (FileNotFoundError, json.JSONDecodeError):
                pass
            self.wfile.write(b'{}')
            return

        # Static-file routes
        if path in ROUTES:
            file_path, ctype = ROUTES[path]
            try:
                with open(file_path, 'rb') as f:
                    body = f.read()
                self._send_headers(200, ctype)
                self.wfile.write(body)
                return
            except FileNotFoundError:
                self.send_error(404, f'Missing file: {file_path}')
                return

        self.send_error(404, f'Unknown route: {path}')

print(f"Captions server listening on http://localhost:{PORT}")
print(f"  Routes: {', '.join(sorted(ROUTES.keys()))} + /latest")
HTTPServer(('localhost', PORT), CaptionHandler).serve_forever()
PYEOF
