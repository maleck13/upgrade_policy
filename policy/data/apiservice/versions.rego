package apiService

versions := [
                  {
                     "service":"apiService",
                     "version":"1.8.0",
                     "meta":{
                        "serviceImpacting":false,
                        "criticalSecurityUpgrade":false
                     },
                     "next":[
                        "1.9.0"
                     ],
                     "dependencies":{
                        "platform":">=4.7.0"
                     }
                  },
                  {
                     "service":"apiService",
                     "version":"1.9.0",
                     "meta":{
                        "serviceImpacting":false,
                        "criticalSecurityUpgrade":false
                     },
                     "next":[],
                     "dependencies":{
                        "platform":">=4.8.0"
                     }
                  }
               ]