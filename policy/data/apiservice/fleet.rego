package apiService

fleet :=[
              {
                 "clusterID":"0",
                 "cloud":"aws",
                 "labels":{},
                 "members":[
                    {
                       "name":"apiService",
                       "version":"1.8.0",
                       "subscription":"1",
                       "id":1,
                       "risk":7,
                       "upgradeStatus":[
                          {
                             "version":"1.8.0",
                             "status":"successful"
                          }
                       ]
                    }
                 ],
                 "services":[
                    {
                       "name":"foo",
                       "version":"2.5.1"
                    },
                    {
                       "name":"observability",
                       "version":"1.2.1"
                    },
                    {
                        "name":"platform",
                        "version":"4.8.10"
                    }

                 ]
              },
              {
                 "clusterID":"1",
                 "cloud":"aws",
                 "labels":{},
                 "members":[
                   {
                       "name":"apiService",
                       "version":"1.8.0",
                       "subscription":"2",
                       "id":2,
                       "risk":1,
                       "upgradeStatus":[
                          {
                             "version":"1.8.0",
                             "status":"successful"
                          }
                       ]
                    }
                 ],
                 "services":[
                    {
                       "name":"foo",
                       "version":"2.5.1"
                    },
                    {
                       "name":"observability",
                       "version":"1.2.1"
                    },
                    {
                        "name":"platform",
                        "version":"4.8.1"
                    }
                 ]
              },
              {
                 "clusterID":"2",
                 "cloud":"aws",
                 "labels":{},
                 "members":[
                   {
                       "name":"apiService",
                       "version":"1.8.0",
                       "subscription":"3",
                       "id":3,
                       "risk":5,
                       "upgradeStatus":[
                          {
                             "version":"1.8.0",
                             "status":"successful"
                          }
                       ]
                    }
                 ],
                 "services":[
                    {
                       "name":"foo",
                       "version":"2.5.1"
                    },
                    {
                       "name":"observability",
                       "version":"1.2.1"
                    },
                    {
                        "name":"platform",
                        "version":"4.8.1"
                    }
                 ]
              }
           ]