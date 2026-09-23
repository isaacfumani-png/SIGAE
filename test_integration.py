import os
import urllib.request
import json

BASE_URL = "https://fadvfvevitqcvyazzrtt.supabase.co/rest/v1"
PUBLISHABLE_KEY = "sb_publishable_Mmicx17voeM8ZLOkTCdiLQ_RM9AGQUX"
SECRET_KEY = os.environ.get("SUPABASE_SECRET_KEY", PUBLISHABLE_KEY)

def request(endpoint, method="GET", data=None):
    url = f"{BASE_URL}/{endpoint}"
    headers = {
        "apikey": SECRET_KEY,
        "Authorization": f"Bearer {SECRET_KEY}",
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
    print(f"Status: {status}, Total modalidades: {len(data) if isinstance(data, list) else 0}")
    assert status == 200 and isinstance(data, list), "Modalidades test failed"

    print("--- Test 2: Query Alunos ---")
    status, data = request("alunos?select=*")
    print(f"Status: {status}, Total alunos: {len(data) if isinstance(data, list) else 0}")
    assert status == 200 and isinstance(data, list), "Alunos test failed"

    print("--- Test 3: Query Turmas Resumo View ---")
    status, data = request("vw_turmas_resumo?select=*")
    print(f"Status: {status}, Total turmas: {len(data) if isinstance(data, list) else 0}")
    assert status == 200 and isinstance(data, list), "Turmas view test failed"

    print("\nAll integration tests passed successfully!")

if __name__ == "__main__":
    run_integration_tests()
