# LoginTokyoTechPortal
[![Swift Version](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

LoginTokyoTechPortal is swift framework of automatic login [TokyoTechPortal](http://portal.titech.ac.jp)

## Installation

### Carthage
`github "nanashiki/LoginTokyoTechPortal"`

### Manually
Drag the `LoginTokyoTechPortal` Folder into your project.

## Usage

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

## Play Sample Project
### 1.Install Xcode
Install Xcode from [Mac App Store](http://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12) (It may take long time)
### 2.Install Carthage
Install Carthage from [Carthage(Github)](https://github.com/Carthage/Carthage/releases)

### 3.Git clone
```
cd ~/Documents
git clone https://github.com/nanashiki/LoginTokyoTechPortal.git
```

### 4.Install External Framwork using Carthage
```
cd LoginTokyoTechPortal
carthage update
```
### 5.Open project
```
open LoginTokyoTechPortal.xcodeproj
```
### 6.Buid And Run
Select scheme `Sample`
![](https://raw.githubusercontent.com/wiki/nanashiki/LoginTokyoTechPortal/Image/TitechApp_README_Image_1.png)

Finaly, `Run`
