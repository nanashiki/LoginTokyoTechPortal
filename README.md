# LoginTokyoTechPortal
LoginTokyoTechPortal is swift framework of automatic login [TokyoTechPortal](http://portal.titech.ac.jp)

##Installation

###Carthage
`github "nanashiki/LoginTokyoTechPortal"`

###Manually
Drag the `LoginTokyoTechPortal` Folder into your project.

##Usage

``` swift
let login = Login.sharedInstance
login.loginInfo = LoginInfo(
  account: "13B00000",
  password: "password",
  matrixcode: ["A1","A2"..."J6","J7"]
)
        
login.start(completion: {
  status in
  switch status {
  case .Success:
    print("Login Success")
  case .AccountPasswordNG:
    print("AccountPasswordNG")
  case .MatrixcodeNG:
     print("MatrixcodeNG")
  case .NetworkError:
    print("NetworkError")
  }
})
```
