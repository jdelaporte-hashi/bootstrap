# This section grants all access on "kvv2/data/*". further restrictions can be
# applied to this broad policy, as shown below.
path "kvv2/data/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
