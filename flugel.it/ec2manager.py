import boto3
import json
import os
from ec2_metadata import ec2_metadata
from http.server import BaseHTTPRequestHandler, HTTPServer

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/tags':
            self.showtags()
        elif self.path == '/shutdown':
            self.shutdown()
        else:
            self.send_error(404, "Page Not Found {}".format(self.path))

    def showtags(self):
        self.send_response(200)
        self.send_header('Content-type','application/json')
        self.end_headers()
        instance_id = ec2_metadata.instance_id
        region = ec2_metadata.region
        ec2 = boto3.resource('ec2', region_name=region)
        tags = ec2.Instance(instance_id).tags
        self.wfile.write(bytes(json.dumps(tags), 'utf-8'))

    def shutdown(self):
        os.system('sudo shutdown now')
        self.send_response(200)

with HTTPServer(('', 8000), handler) as server:
    server.serve_forever()