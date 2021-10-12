package play

# https://play.openpolicyagent.org/p/exsmhl4qlh

# percentage of a given group that need to succeed before the next group is eligible to receive the upgrade
default successThreshold = 90

successThreshold = st{
  not input.successThreshold < 0
  st = input.successThreshold
}

default eligibleForVersion = false

eligibleForVersion{
	eligibleEnvironment
   dependenciesMet
}

default upgradeToVersion = false

upgradeToVersion{
    inActiveGroup
    eligibleForVersion
}

default inActiveGroup = false
inActiveGroup{
 # no previous group so def in active group
 input.previousGroup.total == 0
}

inActiveGroup{
 # previous group success crit met
 (input.previousGroup.success / (input.previousGroup.total - input.previousGroup.ineligible)) * 100 >= successThreshold
}

default eligibleEnvironment = false
  
eligibleEnvironment {
  count(input.version.meta.environments) == 0
}



#environment set so check the cluster environment label matches
eligibleEnvironment{
  count(input.version.meta.environments) > 0
  input.version.meta.environments[_] == input.fleetMember.labels.environment
}

#no environment label all good
eligibleEnvironment{
  not input.version.meta.environments
}

dependenciesMet {
    onClusterDeps := input.fleetMember.services
    count({x |
    vers := input.version.dependencies[x];
    dependencyMet(x,vers,onClusterDeps)}) == count(input.version.dependencies)

}

#>= dependency
dependencyMet(name,version, available) = true {
   startswith(version, ">=")
   vers := replace(version, ">=", "")
   semver.is_valid(vers)
   some i
   available[i].name == name
   semver.compare(available[i].version, vers) >= 0
}

#== dependency
dependencyMet(name,version, available) = true {
   some i
   available[i].name == name
   semver.is_valid(version)
   semver.compare(available[i].version, version) == 0
}

#> dependency
dependencyMet(name,version, available) = true {
   startswith(version, ">")
   vers := replace(version, ">", "")
   some i
   available[i].name == name
   semver.is_valid(vers)
   semver.compare(available[i].version, vers) > 0
}

dependencyMet(name,version, available) = true {
   startswith(version, "<")
   vers := replace(version, "<", "")
   semver.is_valid(vers)
   some i
   available[i].name == name
   semver.compare(available[i].version, vers) == -1
}

dependencyMet(name,version, available) = true {
   startswith(version, "<=")
   vers := replace(version, "<=", "")
   semver.is_valid(vers)
   some i
   available[i].name == name
   semver.compare(available[i].version, vers) <= 0
}


currentVersion = v{
   some i
   vers := input.versions[i]
   # check the fleet member has the service running
   input.fleetMember.name == vers.service
   input.fleetMember.version == vers.version
   v := vers
}

# get the next version based on the version info
nextVersion = v{
   some i
   c := currentVersion
   # simplistic policy of taking the latest version in the next array could be made more complex (IE move through each version starting with the latest until a version is found they are eligible for or none).
   nv := c.next[count(c.next)-1]
   vers = input.versions[i]
   vers.version == nv
   v := vers
}