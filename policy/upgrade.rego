package upgrade.rollout




#build a set of fleet members on a specified cluster who should be upgraded and what version they should be upgraded to. return [{"id":"1","targetVersion":"3.6.0"}]
availableUpgrades[n]{
 some i
  # The fleet is grouped for each version by risk (both those that have already upgraded and those that could)
 groups := groupByVersionAndRisk
  # for each fleet member on the specified cluster, get the next version
 fleet[i].clusterID == input.cid
 fm := fleet[i].members[_]
 nv := nextVersion(fm)
 #get the rollout plan for this members next version
 versionRolloutGroups := groups[_][nv.version]
 # get the group they are in and the previous group check the previous group has met its success criterea or are they in the first group
 inActiveGroup(versionRolloutGroups, fm.id)
 # check they are eligible for the version
 eligibleForVersion(nv,fm)

 n :={
    "id":fm.id,
    "targetVersion":nv,
    "risk":fm.risk
 }

}

fleet[f]{
  service := input.service
  f := data[service].fleet[_]
}

versions[v]{
  service := input.service
  v := data[service].versions[_]
}

fleetMembers[s]{
 s := fleet[_].members[_]
 s.name == versions[_].service
}

services[d]{
  some i
  id := input.cid
  fleet[i].clusterID = id
  d := fleet[i].services[_]
}

cluster = c{
 some i
  id := input.cid
  fleet[i].clusterID = id
  c := fleet[i]
}

#is this service instance on a version less the sent version (posss should look for any fleet members that have a version that has this version in the next array)
groupForVersion(s,v) = true{
   semver.compare(s.version, v.version) == -1
}


#has this service instance attempted an upgrade to the version
groupForVersion(s,v) = true{
   s.upgradeStatus[_].version == v.version
}


# iterate through all versions grouping fleet by who could or has upgraded for each version
# for each version we build an array comprehension and then assign to an object
versionToFleet[r]{
	v := versions[_]
    r := {
    	"version":v,
        "members":[m |
          s := fleetMembers[_]
          groupForVersion(s,v)
          m := s
        ]
    }
}



currentVersion(s) = v{
   some i
   vers := versions[i]
   # check the fleet member has the service running
   s.name == vers.service
   s.version == vers.version
   v :={
      "version": vers,
      "index": i,
      "service": s
   }
}

# get the next version based on the version info
nextVersion(s) = v{
   some i
   c := currentVersion(s)
   nv := c.version.next[count(c.version.next)-1]
   vers = versions[i]
   vers.version == nv
   v := vers
}

# sort the fleet members by risk highest to lowest
sortedRisk(vf) = r{
	ef := vf.members
    risk := {x | x := ef[i].risk}
    sr := sort(risk)
    r := reverse(sr)
}

reverse(l) = [l[j] | _ = l[i]; j := (count(l) - 1) - i]


#group each fleet member into the versions they could upgrade too and have upgraded too in groups defined by their risk tolerance
groupByVersionAndRisk[g]{
		vf := versionToFleet[_]
        # get all the risk levels sorted highest to lowest in the fleet
        sr := sortedRisk(vf)
        # create the rollout groups for the version based on these risk levels
        rolloutGroups := [group |
          risk := sr[i]
          groupMembers := [fm |
          some l
          ef := vf.members
          ef[l].risk == risk
          fm := ef[l] ] # all the members of the same risk eligble for the same version

          #there must be a more efficient way to do this. Count up all sucessful and failed upgrades within a rollout group
          success := [s |
             some o,p
             groupMembers[o].upgradeStatus[p].version == vf.version.version
             groupMembers[o].upgradeStatus[p].status == "successful"
             s := groupMembers[o].upgradeStatus[p]
          ]

          failure := [f |
            some b,c
            groupMembers[b].upgradeStatus[c].version == vf.version.version
            groupMembers[b].upgradeStatus[c].status == "failed"
            f := groupMembers[b].upgradeStatus[c]
          ]
          group := {"index":i, "members":groupMembers, "status":{"success":count(success),"failure":count(failure), "total":count(groupMembers)}}

        ]

        g := {vf.version.version:rolloutGroups}
}

# percentage of a given group that need to succeed before the next group is eligible to receive the upgrade
successCrit = 100

#are they in the first group
inActiveGroup(vgs, id) = true{
  some i
  rolloutGroup := vgs[i]
  rolloutGroup.members[_].id == id
  i == 0
}

#has the previous group met success crit
inActiveGroup(vgs, id) = true{
  some i
  rolloutGroup := vgs[i]
  rolloutGroup.members[_].id == id
  i > 0
  previous := vgs[i-1]
  #total success in the group by total fleet members in the group
  (previous.status.success / previous.status.total) * 100 >= successCrit
}



# do they meet the requirements for the chosen version
eligibleForVersion(v,s) = true{
  eligibleEnvironment(v)
  dependenciesMet(v,s)
}



# is it critical if so auto eligible
eligibleForVersion(v,s) = true{
    v.meta.criticalSecurityUpgrade == true
}


dependenciesMet(v,s) = true{
    onClusterDeps := services
    count({x |
    vers := v.dependencies[x];
    dependencyMet(x,vers,onClusterDeps)}) == count(v.dependencies)

}

#>= dependency
dependencyMet(name,version, available) = true {
   startswith(version, ">=")
   vers := replace(version, ">=", "")
   some i
   available[i].name == name
   semver.compare(available[i].version, vers) >= 0
}
#== dependency
dependencyMet(name,version, available) = true {
   some i
   available[i].name == name
   semver.compare(available[i].version, version) == 0
}

#> dependency
dependencyMet(name,version, available) = true {
   startswith(version, ">")
   vers := replace(version, ">", "")
   some i
   available[i].name == name
   semver.compare(available[i].version, version) > 0
}

dependencyMet(name,version, available) = true {
   startswith(version, "<")
   vers := replace(version, "<", "")
   some i
   available[i].name == name
   semver.compare(available[i].version, version) == -1
}

dependencyMet(name,version, available) = true {
   startswith(version, "<=")
   vers := replace(version, "<=", "")
   some i
   available[i].name == name
   semver.compare(available[i].version, version) <= 0
}


#empty environment set so all good
eligibleEnvironment(v)=true{
  c := cluster
  count(v.meta.environments) == 0
}



#environment set so check the cluster environment label matches
eligibleEnvironment(v)=true{
  c := cluster
  count(v.meta.environments) > 0
  v.meta.environments[_] == c.labels.environment
}

#no environment label all good
eligibleEnvironment(v)=true{
  c := cluster
  not v.meta.environments
}


