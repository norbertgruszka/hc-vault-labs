# Source: https://hvac.readthedocs.io/en/stable/usage/index.html#initialize-and-seal-unseal

import hvac
import os

client = hvac.Client(url=os.getenv('VAULT_ADDR'))
print(client.sys.is_initialized()) # => False

shares = 5
threshold = 3

result = client.sys.initialize(shares, threshold)

root_token = result['root_token']
keys = result['keys']
print(keys)

print(client.sys.is_initialized()) # => True
print(client.sys.is_sealed()) # => True
client.sys.submit_unseal_keys(keys=keys)
print(client.sys.is_sealed()) # => Falses

client.token = root_token

client.sys.enable_auth_method(
    method_type='approle',
)

# client.auth.approle.create_or_update_approle(
#     role_name='some-role',
#     token_policies=['some-policy'],
#     token_type='service,
# )