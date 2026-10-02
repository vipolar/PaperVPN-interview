import json

def handler(event, context):
    path = event.get("rawPath", "/")
    method = event.get("requestContext", {}).get("http", {}).get("method")

    if method != "GET":
        return response(405, {"error": "Method not allowed"})

    routes = {
        "/guest": {
            "route": "guest",
            "message": "Hello, guest"
        },
        "/user": {
            "route": "user",
            "message": "Hello, user"
        },
        "/admin": {
            "route": "admin",
            "message": "Hello, admin"
        }
    }

    if path not in routes:
        return response(404, {"error": "Not found"})

    return response(200, routes[path])

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
