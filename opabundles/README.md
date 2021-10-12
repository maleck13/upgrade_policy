# Adding data to OPA

# Adding data directly via the API

https://www.openpolicyagent.org/docs/latest/rest-api/#data-api

```bash
opa run --server
```

## AddOn Versions
```
curl -X PUT --data '@./opabundles/addons/managed-api-service/versions/data.json' localhost:8181/v1/data/managed-api-service/versions
curl localhost:8181/v1/data/managed-api-service/versions?pretty=true
```

## AddOn Fleet
```
curl -X PUT --data '@./opabundles/addons/managed-api-service/fleet/data.json' localhost:8181/v1/data/managed-api-service/fleet
curl localhost:8181/v1/data/managed-api-service/fleet?pretty=true
```

# Adding data via bundle server

https://www.openpolicyagent.org/docs/latest/management-bundles/

## Create a single bundle:

```bash
tar --exclude bundle.tar.gz --exclude .manifest -czvf opabundles/bundle.tar.gz -h -C opabundles/addons . -C ../streams . -C ../policies .
./
./prow-operator/
./prow-operator/versions/
./prow-operator/versions/data.json
./prow-operator/fleet/
./prow-operator/fleet/data.json
./managed-api-service/
./managed-api-service/versions/
./managed-api-service/versions/data.json
./managed-api-service/fleet/
./managed-api-service/fleet/data.json
./
./streams/
./streams/versions/
./streams/versions/data.json
./streams/fleet/
./streams/fleet/data.json
./
./upgrade/
./upgrade/upgrade.rego
```

### Test locally

```bash
opa run --server --bundle ./opabundles/bundle.tar.gz
```

```bash
curl -s localhost:8181/v1/data/managed-api-service/versions?pretty=true | jq .result[].version
"1.8.0"
"1.9.0"
curl -s localhost:8181/v1/data/managed-api-service/fleet?pretty=true | jq .result[].clusterID
"0"
"1"
"2"
curl -s localhost:8181/v1/policies | jq .result[].id
"opabundles/bundle.tar.gz/upgrade/upgrade.rego"
```

## Create multiple bundles

```bash
tar --exclude bundle.tar.gz -czvf opabundles/addons/bundle.tar.gz -h -C opabundles/addons . &&
 tar --exclude bundle.tar.gz -czvf opabundles/policies/bundle.tar.gz -h -C opabundles/policies . && 
 tar --exclude bundle.tar.gz -czvf opabundles/streams/bundle.tar.gz -h -C opabundles/streams .
./
./prow-operator/
./prow-operator/versions/
./prow-operator/versions/data.json
./prow-operator/fleet/
./prow-operator/fleet/data.json
./managed-api-service/
./managed-api-service/versions/
./managed-api-service/versions/data.json
./managed-api-service/fleet/
./managed-api-service/fleet/data.json
./.manifest
./
./upgrade/
./upgrade/upgrade.rego
./.manifest
./
./streams/
./streams/versions/
./streams/versions/data.json
./streams/fleet/
./streams/fleet/data.json
./.manifest
```

### Test locally

```bash
opa run --server --bundle ./opabundles/addons/bundle.tar.gz ./opabundles/streams/bundle.tar.gz ./opabundles/policies/bundle.tar.gz
```

```bash
curl -s localhost:8181/v1/data/managed-api-service/versions?pretty=true | jq .result[].version
"1.8.0"
"1.9.0"
curl -s localhost:8181/v1/data/managed-api-service/fleet?pretty=true | jq .result[].clusterID
"0"
"1"
"2"
curl -s localhost:8181/v1/policies | jq .result[].id
"opabundles/policies/bundle.tar.gz/upgrade/upgrade.rego"
```

## Run OPA server configured to pull data from local bundle server

### Terminal 1

Start the bundle server:

```bash
cd opa
go run bundle-server.go
```

### Terminal 2

Check the bundle server is serving files:

```
curl localhost:3000/addons/.manifest
{
  "roots": ["managed-api-service", "prow-operator"]
}
```

Start opa with the required configuration:

```bash
opa run -s -c opa/config.yaml 
{"addrs":[":8181"],"diagnostic-addrs":[],"level":"info","msg":"Initializing server.","time":"2021-07-09T10:14:49+01:00"}
{"level":"info","msg":"Starting bundle loader.","name":"addons","plugin":"bundle","time":"2021-07-09T10:14:49+01:00"}
{"level":"info","msg":"Starting bundle loader.","name":"policies","plugin":"bundle","time":"2021-07-09T10:14:49+01:00"}
{"level":"info","msg":"Starting bundle loader.","name":"streams","plugin":"bundle","time":"2021-07-09T10:14:49+01:00"}
{"level":"info","msg":"Bundle loaded and activated successfully.","name":"addons","plugin":"bundle","time":"2021-07-09T10:14:49+01:00"}
{"level":"info","msg":"Bundle loaded and activated successfully.","name":"streams","plugin":"bundle","time":"2021-07-09T10:14:49+01:00"}
{"level":"info","msg":"Bundle loaded and activated successfully.","name":"policies","plugin":"bundle","time":"2021-07-09T10:14:49+01:00"}
```

### Terminal 3

Check the opa server has the expected data and policies from the bundles:

```bash
curl -s localhost:8181/v1/data/managed-api-service/versions?pretty=true | jq .result[].version
"1.8.0"
"1.9.0"
curl -s localhost:8181/v1/data/managed-api-service/fleet?pretty=true | jq .result[].clusterID
"0"
"1"
"2"
curl -s localhost:8181/v1/policies | jq .result[].id
"policies/upgrade/upgrade.rego"
```

Verify that the upgrade policy is working:

```bash
curl -s localhost:8181/v1/data/upgrade/rollout/availableUpgrades -d '{"input":{"cid":"0","service":"managed-api-service"}}' | jq
{
  "result": [
    {
      "id": 1,
      "risk": 7,
      "targetVersion": {
        "dependencies": {
          "platform": ">=4.8.0"
        },
        "meta": {
          "criticalSecurityUpgrade": false,
          "serviceImpacting": false
        },
        "next": [],
        "service": "managed-api-service",
        "version": "1.9.0"
      }
    }
  ]
}

```
