# upgrade_policy
OPA policy examples for upgrades




# What is in this repo

There is an upgrade policy and then sets of data representing a fleet of different services that are in various states. The policy 
can make a decision who should be upgraded and to what version based on this data.


# What does the policy do

## Phased Roll Out

Roll out the upgrade in phases. Each phase is represented by a group of fleet members that share a common risk tolerance.

The policy looks at the available versions. It then groups the entire fleet for each version it has based on:
 - A risk attribute on each fleet member 
 - If the fleet member could upgrade to the version 
 - If they have already upgraded to the version. 

It then takes each fleet member on a specified cluster and finds out what the next version for that fleet member is. Then it checks
if the fleet member is in an active group:
- for the version this member is going to, are they in the first group
- If not has the group previous to this member's group met the success threshold


## Eligibility
Finally it checks if they are eligible to receive the upgrade:

- Does the cluster this fleet member is on have the required dependencies
  - platform version
  - other supporting services
- is this fleet member on a cluster labelled with the correct environment 

## Future Enhancements

### report a reason if no available upgrades
### report a reason for any member that failed the policy
### change success to be based on eligible members only

# Try it out

- Download OPA https://www.openpolicyagent.org/docs/latest/#running-opa
- Clone this repo
- Start OPA as a server loading the policy and data

` opa run --server policy/upgrade.rego policy/data/apiservice/versions.rego policy/data/apiservice/fleet.rego policy/data/streams/fleet.rego policy/data/streams/versions.rego `

- In a separate window. Make a request to get available upgrades:

` curl localhost:8181/v1/data/upgrade/rollout/availableUpgrades -d @./input/input.json -H 'Content-Type: application/json' | jq `

You will see all the available upgrades are for fleet members on cluster 0 with a risk of 7 set.

- Change the input ` vi input/input.json ` and set the cid to 1
- Rerun the query and it will return 1 fleet member on that cluster with risk of 7
- change the data

` opa run --server policy/upgrade.rego policy/data/apiservice/versions.rego policy/data/apiservice/fleet.rego policy/data/streams/fleet_1.rego policy/data/streams/versions.rego `

- Change the input ` vi input/input.json ` and set the cid to 0
- Rerun the query
- No there is only 1 cluster on cid 0 as the other cluster has successfully upgraded.


- change the data again so that now all the 7s in the fleet have upgraded.

` opa run --server policy/upgrade.rego policy/data/apiservice/versions.rego policy/data/apiservice/fleet.rego policy/data/streams/fleet_2.rego policy/data/streams/versions.rego `

- Rerun the query and now you will get a set of clusters with risk level 5

- next we change the data to make the cluster 0 inelligable for the upgrade by changing the version of a dependency needed by the version 3.6.0. These dependencies are stored in the version information

` opa run --server policy/upgrade.rego policy/data/apiservice/versions.rego policy/data/apiservice/fleet.rego policy/data/streams/fleet_3.rego policy/data/streams/versions.rego `

- Rerun the query and now we will get no available upgrades for cluster 0 as the cluster cannot meet the requirements for the version

- Change the input to cid 1 and we still have one available upgrade as that cluster can meet the requirements.

- Finally change the data one last time. Now cluster 0 is still ineligible and all the members of cluster 1 have successfully upgraded. If we re-run the query (changing the input as needed for each cluster), there are no more available upgrades as the phase with members of risk 7 has not hit the success threshold.

` opa run --server policy/upgrade.rego policy/data/apiservice/versions.rego policy/data/apiservice/fleet.rego policy/data/streams/fleet_4.rego policy/data/streams/versions.rego `
