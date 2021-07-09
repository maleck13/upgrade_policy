package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/open-policy-agent/opa/rego"
)

func main() {

	ctx := context.TODO()
	f, err := loadFleet("../opabundles/addons/managed-api-service/fleet/data.json")
	if err != nil {
		panic(err)
	}

	v, err := loadVersions("../opabundles/addons/managed-api-service/versions/data.json")
	if err != nil {
		panic(err)
	}

	fv := &FleetVersions{
		ClusterID: "0",
		Fleet:     f,
		Versions:  v,
	}

	d, _ := json.MarshalIndent(fv, "", " ")
	fmt.Println(string(d))

	executePolicy(ctx, fv)
}

func loadPolicy() (string, error) {
	res, err := http.Get("http://localhost:8181/v1/policies/opabundles/policies/upgrade/upgrade.rego")
	if err != nil {
		return "", err
	}
	defer res.Body.Close()
	dec := json.NewDecoder(res.Body)
	p := &Policy{}
	if err := dec.Decode(p); err != nil {
		return "", err
	}
	return p.Result.Raw, nil

}

func loadFleet(path string) (*fleet, error) {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	f := &fleet{}
	if err := json.Unmarshal(data, f); err != nil {
		return nil, err
	}
	return f, nil
}

func loadVersions(path string) (*versions, error) {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	v := &versions{}
	if err := json.Unmarshal(data, v); err != nil {
		return nil, err
	}
	return v, nil
}

func executePolicy(ctx context.Context, fv *FleetVersions) error {
	p, err := loadPolicy()
	if err != nil {
		return err
	}
	q, err := rego.New(
		rego.Query("data.upgrade.rollout.availableUpgrades"),
		rego.Module("upgrade.rego", p),
	).PrepareForEval(ctx)

	if err != nil {
		return err
	}
	r, err := q.Eval(ctx, rego.EvalInput(fv))
	if err != nil {
		return err
	}
	fmt.Println(r)
	return nil
}

type Policy struct {
	Result *Result `json:"result"`
}

type Result struct {
	Raw string `json:"raw"`
}

type fleet []*FleetMember
type versions []*Version

type FleetVersions struct {
	ClusterID string    `json:"cid"`
	Fleet     *fleet    `json:"fleet"`
	Versions  *versions `json:"versions"`
}

type FleetMember struct {
	Clusterid string `json:"clusterID"`
	Cloud     string `json:"cloud"`
	Labels    struct {
	} `json:"labels"`
	Members []struct {
		Name          string `json:"name"`
		Version       string `json:"version"`
		Subscription  string `json:"subscription"`
		ID            int    `json:"id"`
		Risk          int    `json:"risk"`
		Upgradestatus []struct {
			Version string `json:"version"`
			Status  string `json:"status"`
		} `json:"upgradeStatus"`
	} `json:"members"`
	Services []struct {
		Name    string `json:"name"`
		Version string `json:"version"`
	} `json:"services"`
}

type Version struct {
	Service string `json:"service"`
	Version string `json:"version"`
	Meta    struct {
		Serviceimpacting        bool `json:"serviceImpacting"`
		Criticalsecurityupgrade bool `json:"criticalSecurityUpgrade"`
	} `json:"meta"`
	Next         []string `json:"next"`
	Dependencies struct {
		Platform string `json:"platform"`
	} `json:"dependencies"`
}
