//
//  Login.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

public enum LoginStatus : Int{
    case Init
    case NowLogin
    case NetworkError
    case TopPageNG
    case AccountPasswordOK
    case AccountPasswordNG
    case MatrixcodeNG
    case UnknownError
    case Success
}

public enum LoginNotification : String{
    case start = "LoginStart"
    case success = "LoginSuccess"
    case fail = "LoginFail"
}

public extension String {
    func escapeStr() -> String {
        let raw: NSString = self
        let allowedCharacterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        allowedCharacterSet.addCharactersInString("-._~")
        return raw.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
    }
}

public class Login: NSObject {
    //sharedInstance
    public static let sharedInstance = Login()
    
    //Status
    public private (set) var status:LoginStatus = .Init
    public private (set) dynamic var progress = 0
    
    //LoginDic
    let loginDic : [String:String]
    
    //LoginInfo
    public var loginInfo = LoginInfo(account: nil, password: nil, matrixcode: nil)
    
    //Matrix Numbers
    public private (set) var matrixNums = [Int]()
    
    //Matrixs
    public private (set) var matrixs = [String]()
    
    //OCWi html String
    public private (set) var ocwiHtml = ""
    
    private override init() {
        if let path = NSBundle(forClass: self.dynamicType).pathForResource("Login", ofType: "plist"){
            if let dic : [String:String] = NSDictionary(contentsOfFile: path) as? [String:String]{
                loginDic = dic
            }else{
                loginDic = Dictionary()
            }
        }else{
            loginDic = Dictionary()
        }
    }
    
    public func start(completion completion:((LoginStatus)->())? = nil){
        if status == .NowLogin {
            completion?(self.status)
            self.postNotification(.fail)
            return
        }
        
        self.postNotification(.start)
        progress = 0
        self.logout(loginTitanetWireless: true, completion: {success in
            if !success {
                completion?(self.status)
                self.postNotification(.fail)
                return
            }
            self.login_TopPage(loginTitanetWireless: true, completion: {success,html in
                if !success {
                    completion?(self.status)
                    self.postNotification(.fail)
                    return
                }
                self.login_AccountPassword(html: html, account: self.loginInfo.account, password: self.loginInfo.password, completion: {success,html in
                    if !success {
                        completion?(self.status)
                        self.postNotification(.fail)
                        return
                    }
                    self.progress = 1
                    self.login_Matrixcode(html: html, matrixcode: self.loginInfo.matrixcode, completion: {success,html in
                        if !success {
                            completion?(self.status)
                            self.postNotification(.fail)
                            return
                        }
                        self.progress = 2
                        self.login_OCWi(completion: {success in
                            if !success {
                                completion?(self.status)
                                self.postNotification(.fail)
                                return
                            }
                            self.progress = 3
                            completion?(self.status)
                            self.postNotification(.success)
                        })
                    })
                })
            })
        })
    }
    
    public func check(account account : String,password: String,completion:((Bool)->())?){
        self.logout(loginTitanetWireless: true, completion: {success in
            if !success {
                completion?(success)
                return
            }
            self.login_TopPage(loginTitanetWireless: true, completion: {success,html in
                if !success {
                    completion?(success)
                    return
                }
                self.login_AccountPassword(html: html, account: account, password: password, completion: {success,html in
                    self.status = success ? .AccountPasswordOK:.AccountPasswordNG
                    completion?(success)
                })
            })
        })
    }
    
    public func check(matrixcode matrixcode:[String],completion:((Bool)->())?){
        self.logout(loginTitanetWireless: true, completion: {success in
            if !success {
                completion?(success)
                return
            }
            self.login_TopPage(loginTitanetWireless: true, completion: {success,html in
                if !success {
                    completion?(success)
                    return
                }
                self.login_AccountPassword(html: html, account: self.loginInfo.account, password: self.loginInfo.password, completion: {success,html in
                    if !success {
                        completion?(success)
                        return
                    }
                    self.login_Matrixcode(html: html, matrixcode: matrixcode, completion: {success,html in
                        if !success {
                            completion?(success)
                            return
                        }
                        self.login_OCWi(completion: {success in
                            completion?(success)
                        })
                    })
                })
            })
        })
    }
    
    private func logout(loginTitanetWireless loginTitanetWireless:Bool, completion:(Bool->())){
        switch status{
        case .Success,.MatrixcodeNG,.AccountPasswordOK:
            status = .NowLogin
            HTTPConnection.getStringFromGETRequest(loginDic["LogoutURL"], completion: {html_ in
                if let _ = html_{
                    print("Logout OK")
                    completion(true)
                }else{
                    if loginTitanetWireless{
                        let loginTW = LoginTitanetWireless.sharedInstance
                        loginTW.loginInfo = self.loginInfo
                        loginTW.start(completion: {status in
                            self.logout(loginTitanetWireless: false, completion: completion)
                        })
                    }else{
                        print("TopPage NetworkError")
                        self.status = .NetworkError
                        completion(false)
                    }
                }
            })
        default:
            status = .NowLogin
            completion(true)
            break;
        }
    }
    
    private func login_TopPage(loginTitanetWireless loginTitanetWireless:Bool, completion:((Bool,String)->())){
        HTTPConnection.getStringFromGETRequest(loginDic["TopPageURL"], completion:{html_ in
            if let html = html_{
                if html.containsString(self.loginDic["TopPageConfirmString"]!){
                    print("TopPage OK")
                    completion(true,html)
                }else{
                    print("TopPage NG")
                    self.status = .TopPageNG
                    completion(false,html)
                }
            }else{
                if loginTitanetWireless{
                    let loginTW = LoginTitanetWireless.sharedInstance
                    loginTW.loginInfo = self.loginInfo
                    loginTW.start(completion: {status in
                        self.login_TopPage(loginTitanetWireless: false, completion: completion)
                    })
                }else{
                    print("TopPage NetworkError")
                    self.status = .NetworkError
                    completion(false,"")
                }
            }
        })
    }
    
    private func login_AccountPassword(html html : String ,account : String, password: String,completion:((Bool,String)->())){
        var postStr = HTTPConnection.getPOSTStringFromHTML(html)
        postStr = postStr.stringByReplacingOccurrencesOfString(loginDic["usr_name="]!,withString: "\(loginDic["usr_name="]!)\(account)")
        postStr = postStr.stringByReplacingOccurrencesOfString(loginDic["usr_password="]!, withString: "\(loginDic["usr_password="]!)\(password.escapeStr())")
        HTTPConnection.getStringFromPOSTRequest(url:loginDic["PostURL"], post: postStr, referer:loginDic["TopPageURL"]!,completion: {html_ in
            if let html = html_{
                if html.containsString(self.loginDic["AccountPasswordConfirmString"]!){
                    print("AccountPassword OK")
                    completion(true,html)
                }else{
                    print("AccountPassword NG")
                    self.status = .AccountPasswordNG
                    completion(false,html)
                }
            }else{
                self.status = .NetworkError
                completion(false,"")
            }
        })
        
    }
    
    
    private func login_Matrixcode(html html: String, matrixcode: Array<String>,completion:((Bool,String)->())){
        guard var matrixArr = RegularExpressionMatch.matchesInString(html, pattern: loginDic["matrixcodeRegularExpressionPattern"]!) else{
            self.status = .UnknownError
            completion(false,"")
            return
        }
        
        let alphabet = ["A","B","C","D","E","F","G","H","I","J"]
        
        var codes = [String]()
        var matrixNums = [Int]()
        var matrixs = [String]()
        
        for var i = 0; i < matrixArr.count ;i++ {
            for var j = 0; j < alphabet.count ; j++ {
                let arr = matrixArr[i]
                if arr[0].containsString(alphabet[j]){
                    let k = Int(arr[1])!
                    codes += [matrixcode[j*7+k-1]]
                    matrixNums += [(j*7+k-1)]
                    matrixs += ["\(alphabet[j])\(k)"]
                }
            }
        }
        
        self.matrixNums = matrixNums
        self.matrixs = matrixs
        
        var postStr = HTTPConnection.getPOSTStringFromHTML(html)
        postStr = postStr.stringByReplacingOccurrencesOfString(loginDic["code1="]!,withString: "\(loginDic["code1="]!)\(codes[0])")
        postStr = postStr.stringByReplacingOccurrencesOfString(loginDic["code2="]!,withString: "\(loginDic["code2="]!)\(codes[1])")
        postStr = postStr.stringByReplacingOccurrencesOfString(loginDic["code3="]!,withString: "\(loginDic["code3="]!)\(codes[2])")
        
        HTTPConnection.getStringFromPOSTRequest(url:loginDic["PostURL"], post: postStr, referer: loginDic["AccountPasswordURL"]!, completion: {
            html_ in
            if let html = html_{
                if html.containsString(self.loginDic["MatrixcodeConfirmString"]!){
                    print("Matrixcode OK")
                    completion(true,html)
                }else{
                    print("Matrixcode NG")
                    self.status = .MatrixcodeNG
                    completion(false,html)
                }
            }else{
                self.status = .NetworkError
                completion(false,"")
            }
        })
    }
    
    private func login_OCWi(completion completion:((Bool)->())){
        HTTPConnection.getStringFromGETRequest(loginDic["OCWiURL"], completion:{html_ in
            if let html = html_{
                print("OCWi OK")
                self.ocwiHtml = html
                self.status = .Success
                completion(true)
            }else{
                print("OCWi NG")
                self.status = .NetworkError
                completion(false)
            }
        })
    }
    
    private func postNotification(loginNotification : LoginNotification){
        NSNotificationCenter.defaultCenter().postNotificationName(loginNotification.rawValue, object: nil, userInfo: nil)
    }
}
