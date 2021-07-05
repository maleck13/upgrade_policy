package streams

versions := [
                  {
                     "service":"streams",
                     "version":"3.4.0",
                     "meta":{
                        "environments":[
                           "staging",
                           "production"
                        ],
                        "serviceImpacting":false,
                        "criticalSecurityUpgrade":false
                     },
                     "next":[
                        "3.5.0"
                     ],
                     "dependencies":{
                           "strimzi":">=2.5.1",
                           "observability":">=1.2.0"
                     }
                  },
                  {
                     "service":"streams",
                     "version":"3.5.0",
                     "meta":{
                        "environments":[
                           "staging"
                        ],
                        "serviceImpacting":false,
                        "criticalSecurityUpgrade":false
                     },
                     "next":[
                        "3.6.0"
                     ],
                     "dependencies":{
                           "strimzi":">=2.5.1",
                           "observability":">=1.2.0"
                        }
                  },
                  {
                     "service":"streams",
                     "version":"3.6.0",
                     "meta":{
                        "environments":[
                           "staging",
                            "production"
                        ],
                        "serviceImpacting":false,
                        "criticalSecurityUpgrade":true
                     },
                     "next":[

                     ],
                     "dependencies":{
                           "strimzi":">=2.5.1",
                           "observability":">=1.2.0"
                        }
                  }
               ]