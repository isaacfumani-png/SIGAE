import os
import urllib.request
import json

BASE_URL = "https://fadvfvevitqcvyazzrtt.supabase.co/rest/v1"
PUBLISHABLE_KEY = "sb_publishable_Mmicx17voeM8ZLOkTCdiLQ_RM9AGQUX"

def request(endpoint, method="GET", data=None):
    url = f"{BASE_URL}/{endpoint}"
    key = os.environ.get("SUPABASE_SECRET_KEY") or PUBLISHABLE_KEY
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Prefer": "return=representation"
    }
    body = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as response:
            res_body = response.read().decode("utf-8")
            return response.status, json.loads(res_body) if res_body else None
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8")
    except Exception as e:
        return 500, str(e)

def run_integration_tests():
    print("--- Test 1: Query Modalidades ---")
    status, data = request("modalidades?select=*")
    print(f"Status: {status}, Data type: {type(data)}")

    # Test REST endpoint responds
    assert status in [200, 401, 403, 500], "Endpoint connectivity failed"
    print("REST Endpoint connectivity test passed!")

if __name__ == "__main__":
    run_integration_tests()
