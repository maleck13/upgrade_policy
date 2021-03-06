package streams

fleet :=[
              {
                 "clusterID":"0",
                 "labels":{
                     "environment":"production"
                 },
                 "cloud":"aws",
                 "platformVersion":"4.7.10",
                 "members":[
                    {
                       "name":"streams",
                       "version":"3.5.0",
                       "subscription":"1",
                       "id":1,
                       "risk":7,
                       "upgradeStatus":[
                          {
                             "version":"3.5.0",
                             "status":"successful"
                          }
                       ]
                    },
                    {
                       "name":"streams",
                       "version":"3.5.0",
                       "subscription":"2",
                       "id":2,
                       "risk":7,
                       "upgradeStatus":[
                          {
                             "version":"3.4.0",
                             "status":"successful"
                          },
                          {
                             "version":"3.5.0",
                             "status":"successful"
                          }
                       ]
                    },
                    {
                       "name":"streams",
                       "version":"3.5.0",
                       "subscription":"3",
                       "id":3,
                       "risk":5,
                       "upgradeStatus":[
                          {
                             "version":"3.4.0",
                             "status":"failed"
                          },
                          {
                             "version":"3.5.0",
                             "status":"successful"
                          }
                       ]
                    },
                    {
                       "name":"streams",
                       "version":"3.5.0",
                       "subscription":"4",
                       "id":4,
                       "risk":5,
                       "upgradeStatus":[
                          {
                             "version":"3.4.0",
                             "status":"failed"
                          },
                          {
                             "version":"3.5.0",
                             "status":"successful"
                          }
                       ]
                    },
                    {
                       "name":"streams",
                       "version":"3.5.0",
                       "subscription":"4",
                       "id":5,
                       "risk":1,
                       "upgradeStatus":[
                          {
                             "version":"3.4.0",
                             "status":"failed"
                          },
                          {
                             "version":"3.5.0",
                             "status":"successful"
                          }
                       ]
                    }
                 ],
                 "services":[
                    {
                       "name":"strimzi",
                       "version":"2.5.1"
                    },
                    {
                       "name":"observability",
                       "version":"1.2.1"
                    }
                 ]
              },
              {
                 "clusterID":"1",
                 "cloud":"aws",
                 "platformVersion":"4.7.10",
                 "labels":{"environment":"production"},
                 "members":[
                    {
                       "name":"streams",
                       "version":"3.5.0",
                       "subscription":"1",
                       "id":6,
                       "risk":7,
                       "upgradeStatus":[
                          {
                             "version":"3.5.0",
                             "status":"successful"
                          }
                       ]
                    }
                 ],
                 "services":[
                    {
                       "name":"strimzi",
                       "version":"2.5.1"
                    },
                    {
                       "name":"observability",
                       "version":"1.2.1"
                    }
                 ]
              }
           ]