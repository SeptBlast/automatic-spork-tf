import json
import time
import random
from urllib.request import urlopen, Request


fixed_name = "nf_cf"
random_name_site = s = ''.join(random.choice(
    [chr(i) for i in range(ord('a'), ord('z'))]) for _ in range(10))

result = {
    "name": f"{random_name_site}-{fixed_name}-{int(time.time())}",
}

print(json.dumps(result))
