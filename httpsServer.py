# Dummy HTTPS server
# Taken from : https://gist.github.com/dragermrb/108158f5a284b5fba806 and other repos
import http.server
import cgi
import base64
import json
from urllib.parse import urlparse, parse_qs
import ssl
import os
import socketserver


class RestrictedHTTPRequestHandler(http.server.CGIHTTPRequestHandler):

    def do_HEAD(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_AUTHHEAD(self):
        self.send_response(401)
        self.send_header(
            'WWW-Authenticate', 'Basic realm="Demo Realm"')
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_GET(self):
        key = self.server.get_auth_key()

        ''' Present frontpage with user authentication. '''
        if self.headers.get('Authorization') == None:
            self.do_AUTHHEAD()

            response = {
                'success': False,
                'error': 'No auth header received'
            }

            self.wfile.write(bytes(json.dumps(response), 'utf-8'))

        elif self.headers.get('Authorization') == 'Basic ' + str(key):

            super().do_GET()

        else:
            self.do_AUTHHEAD()

            response = {
                'success': False,
                'error': 'Invalid credentials'
            }

            self.wfile.write(bytes(json.dumps(response), 'utf-8'))

    def do_POST(self):
        key = self.server.get_auth_key()

        ''' Present frontpage with user authentication. '''
        if self.headers.get('Authorization') == None:
            self.do_AUTHHEAD()

            response = {
                'success': False,
                'error': 'No auth header received'
            }

            self.wfile.write(bytes(json.dumps(response), 'utf-8'))

        elif self.headers.get('Authorization') == 'Basic ' + str(key):
            super().do_POST()

        else:
            self.do_AUTHHEAD()

            response = {
                'success': False,
                'error': 'Invalid credentials'
            }

            self.wfile.write(bytes(json.dumps(response), 'utf-8'))

        response = {
            'path': self.path,
            'get_vars': str(getvars),
            'get_vars': str(postvars)
        }

        self.wfile.write(bytes(json.dumps(response), 'utf-8'))

    def _parse_POST(self):
        ctype, pdict = cgi.parse_header(self.headers.getheader('content-type'))
        if ctype == 'multipart/form-data':
            postvars = cgi.parse_multipart(self.rfile, pdict)
        elif ctype == 'application/x-www-form-urlencoded':
            length = int(self.headers.getheader('content-length'))
            postvars = cgi.parse_qs(
                self.rfile.read(length), keep_blank_values=1)
        else:
            postvars = {}

        return postvars

    def _parse_GET(self):
        getvars = parse_qs(urlparse(self.path).query)

        return getvars


class HTTPSServer(http.server.HTTPServer):
    key = ''

    def __init__(self, address, RequesthandlerClass=RestrictedHTTPRequestHandler):
        super().__init__(address, RequestHandlerClass=RequesthandlerClass)

    def set_auth(self, username, password):
        self.key = base64.b64encode(
            bytes('%s:%s' % (username, password), 'utf-8')).decode('ascii')

    def set_ssl_socket(self, keyfile, certfile, server_side=True, **kwargs):
        self.socket = ssl.wrap_socket(self.socket, keyfile=keyfile, certfile=certfile, server_side=server_side, **kwargs)

    def get_auth_key(self):
        return self.key


if __name__ == '__main__':
    ssl_folder = os.path.expanduser('~/.ssl')
    keyfile = os.path.join(ssl_folder, 'key.pem')
    certfile = os.path.join(ssl_folder, 'cert.pem')
    port = 4443  # Usual 443 requires sudo
    address = ('', port)
    handler = RestrictedHTTPRequestHandler

    httpd = HTTPSServer(address, handler)
    httpd.set_auth('demo', 'demo')
    httpd.set_ssl_socket(keyfile=keyfile, certfile=certfile, server_side=True)
    httpd.serve_forever()
