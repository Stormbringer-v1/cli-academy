#!/usr/bin/env bash
      set -euo pipefail

      DOCKER_GAME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
      source "${DOCKER_GAME_ROOT}/docker_common.sh"

      setup_sandbox() {
        export DOCKER_GAME_PREFIX="cliacademy_boss02_"
        docker_cleanup_prefix "$DOCKER_GAME_PREFIX"
        cat > app.py <<'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'python app ok')
HTTPServer(('0.0.0.0', 8000), H).serve_forever()
EOF
        printf '
' > requirements.txt
      }

      cleanup_sandbox() {
        docker_game_cleanup
      }
