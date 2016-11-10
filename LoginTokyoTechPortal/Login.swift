//
//  Login.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

public enum LoginStatus : Int{
    case Init
    case nowLogin
    case networkError
    case accountPasswordOK
    case accountPasswordNG
    case matrixcodeNG
    case unknownError
    case success
}

public enum LoginNotification : String{
    case start = "LoginStart"
    case success = "LoginSuccess"
    case fail = "LoginFail"
}

fileprivate struct LoginURL {
    static let accountPassword = "https://portal.nap.gsic.titech.ac.jp/GetAccess/Login?Template=userpass_key&AUTHMETHOD=UserPassword"
    static let matrixcode = "https://portal.nap.gsic.titech.ac.jp/GetAccess/Login?Template=idg_key&AUTHMETHOD=IG&GASF=CERTIFICATE,IG.GRID&LOCALE=ja_JP&GAREASONCODE=13&GAIDENTIFICATIONID=UserPassword&GARESOURCEID=resourcelistID2&GAURI=https://portal.nap.gsic.titech.ac.jp/GetAccess/ResourceList&Reason=13&APPID=resourcelistID2&URI=https://portal.nap.gsic.titech.ac.jp/GetAccess/ResourceList"
    static let logout = "https://portal.nap.gsic.titech.ac.jp/GetAccess/Logout"
    static let post = "https://portal.nap.gsic.titech.ac.jp/GetAccess/Login"
    static let ocwi = "https://secure.ocw.titech.ac.jp/ocwi/index.php"
    static let calender = "https://secure.ocw.titech.ac.jp/ocwi/index.php?module=Ocwi&action=Webcal&iCalendarId="
}

fileprivate struct ConfirmString {
    static let accountPassword = "Please input your account & password."
    static let matrixcode = "Matrix Authentication"
    static let success = "リソース メニュー"
}

fileprivate struct FormInputName {
    static let username = "usr_name"
    static let password = "usr_password"
    static let code1 = "message3"
    static let code2 = "message4"
    static let code3 = "message5"
}

fileprivate struct RegexpPattern {
    static let matrixcode = "\\[([A-J]{1}),([1-7]{1})\\]"
    static let calender = "https://secure.ocw.titech.ac.jp/ocwi/index.php\\?module=Ocwi&action=Webcal&iCalendarId=([^\"^']+)"
}

open class Login: NSObject {
    //sharedInstance
    open static let sharedInstance = Login()
    
    //Status
    open fileprivate (set) var status:LoginStatus = .Init
    open fileprivate (set) dynamic var progress = 0
    
    //Portal Account
    open var account = PortalAccount(username: nil, password: nil, matrixcode: nil)
    
    //Matrix Indexs
    open fileprivate (set) var matrixIndexs = [Int]()
    
    //Matrix Values
    open fileprivate (set) var matrixs = [String]()
    
    //OCWi html String
    open fileprivate (set) var ocwiHtml:String?
    
    //OCWi Calendar URL
    open fileprivate (set) var ocwiCalendarURL:String?
    
    //OCWi Assignments
    open var assignments = [Assignment]()
    
    fileprivate override init() {}
    
    open func start(completion:((LoginStatus)->())? = nil){
        if status == .nowLogin {
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
            self.login_AccountPasswordPage(loginTitanetWireless: true, completion: {success,html in
                if !success {
                    completion?(self.status)
                    self.postNotification(.fail)
                    return
                }
                self.login_AccountPassword(html: html, account: self.account.username, password: self.account.password, completion: {success,html in
                    if !success {
                        completion?(self.status)
                        self.postNotification(.fail)
                        return
                    }
                    self.progress = 1
                    self.login_Matrixcode(html: html, matrixcode: self.account.matrixcode, completion: {success,html in
                        if !success {
                            completion?(self.status)
                            self.postNotification(.fail)
                            return
                        }
                        self.progress = 2
                        self.login_OCWi(completion: {success in
                            if !success {
                                completion?(self.status)
                                self.postNotification(.fail)//successでいいかも？
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
    
    open func check(account : String,password: String,completion:((Bool)->())?){
        self.logout(loginTitanetWireless: true, completion: {success in
            if !success {
                completion?(success)
                return
            }
            self.login_AccountPasswordPage(loginTitanetWireless: true, completion: {success,html in
                if !success {
                    completion?(success)
                    return
                }
                self.login_AccountPassword(html: html, account: account, password: password, completion: {success,html in
                    self.status = success ? .accountPasswordOK:.accountPasswordNG
                    completion?(success)
                })
            })
        })
    }
    
    open func check(matrixcode:[String],completion:((Bool)->())?){
        self.logout(loginTitanetWireless: true, completion: {success in
            if !success {
                completion?(success)
                return
            }
            self.login_AccountPasswordPage(loginTitanetWireless: true, completion: {success,html in
                if !success {
                    completion?(success)
                    return
                }
                self.login_AccountPassword(html: html, account: self.account.username, password: self.account.password, completion: {success,html in
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
    
    fileprivate func logout(loginTitanetWireless:Bool, completion:@escaping ((Bool)->())){
        switch status{
        case .success,.matrixcodeNG,.accountPasswordOK:
            status = .nowLogin
            Alamofire.request(LoginURL.logout).responseString(completionHandler: {
                response in
                switch response.result {
                case .success(_):
                    print("Logout OK")
                    completion(true)
                case .failure(let error):
                    if loginTitanetWireless{
                        let loginTW = LoginTitanetWireless.sharedInstance
                        loginTW.account = self.account
                        loginTW.start(completion: {status in
                            if status == .success || status == .alreadySuccess {
                                self.logout(loginTitanetWireless: false, completion: completion)
                            }else{
                                print("Logout NetworkError:\(error)")
                                self.status = .networkError
                                completion(false)
                            }
                        })
                    }else{
                        print("Logout NetworkError:\(error)")
                        self.status = .networkError
                        completion(false)
                    }
                    
                }
            })
        default:
            print("Logout Skip")
            status = .nowLogin
            completion(true)
            break;
        }
    }
    
    fileprivate func login_AccountPasswordPage(loginTitanetWireless:Bool, completion:@escaping ((Bool,String)->())){
        Alamofire.request(LoginURL.accountPassword).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let html):
                if html.contains(ConfirmString.accountPassword){
                    print("AccountPasswordPage OK")
                    completion(true,html)
                    return
                }else{
                    print("AccountPasswordPage NG")
                    self.status = .unknownError
                    completion(false,html)
                }
            case .failure(let error):
                if loginTitanetWireless{
                    let loginTW = LoginTitanetWireless.sharedInstance
                    loginTW.account = self.account
                    loginTW.start(completion: {status in
                        if status == .success || status == .alreadySuccess {
                            self.login_AccountPasswordPage(loginTitanetWireless: false, completion: completion)
                        }else{
                            print("AccountPasswordPage NetworkError:\(error)")
                            self.status = .networkError
                            completion(false,"")
                        }
                    })
                }else{
                    print("AccountPasswordPage NetworkError:\(error)")
                    self.status = .networkError
                    completion(false,"")
                }
            }
        })
    }
    
    fileprivate func login_AccountPassword(html : String ,account : String, password: String,completion:@escaping ((Bool,String)->())){
        guard let doc = HTML(html: html, encoding: String.Encoding.utf8) else{
            return
        }
        
        var parameters = [String:String]()
        
        for input in doc.css("input"){
            guard let name = input["name"] else{
                continue
            }
            
            guard var value = input["value"] else{
                continue
            }
            
            if name == FormInputName.username {
                value = account
            }
            
            if name == FormInputName.password {
                value = password
            }
            
            parameters[name] = value
        }
        
        Alamofire.request(LoginURL.post, method: .post, parameters: parameters, headers: ["Referer":LoginURL.accountPassword]).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let html):
                if html.contains(ConfirmString.matrixcode){
                    print("AccountPassword OK")
                    completion(true,html)
                }else{
                    print("AccountPassword NG")
                    self.status = .accountPasswordNG
                    completion(false,html)
                }
            case .failure(let error):
                print("AccountPassword NetworkError:\(error)")
                self.status = .networkError
                completion(false,"")
            }
        })
    }
    
    
    fileprivate func login_Matrixcode(html: String, matrixcode: Array<String>,completion:@escaping ((Bool,String)->())){
        guard let matrixArr = html.matches(RegexpPattern.matrixcode) else{
            self.status = .unknownError
            completion(false,"")
            return
        }
        
        let alphabets = ["A","B","C","D","E","F","G","H","I","J"]
        
        var codes = [String]()
        var matrixNums = [Int]()
        var matrixs = [String]()
        
        for matrix in matrixArr {
            for alphabet in alphabets.enumerated() {
                if matrix[0].contains(alphabet.element){
                    guard let k = Int(matrix[1]) else{
                        break
                    }
                    codes += [matrixcode[alphabet.offset*7+k-1]]
                    matrixNums += [(alphabet.offset*7+k-1)]
                    matrixs += ["\(alphabet.element)\(k)"]
                }
            }
        }
        
        self.matrixIndexs = matrixNums
        self.matrixs = matrixs
        
        guard let doc = HTML(html: html, encoding: String.Encoding.utf8) else{
            return
        }
        
        var parameters = [String:String]()
        
        for input in doc.css("input"){
            guard let name = input["name"] else{
                continue
            }
            
            guard var value = input["value"] else{
                continue
            }
            
            if name == FormInputName.code1 {
                value = codes[0]
            }
            
            if name == FormInputName.code2 {
                value = codes[1]
            }
            
            if name == FormInputName.code3 {
                value = codes[2]
            }
            
            parameters[name] = value
        }
        
        Alamofire.request(LoginURL.post, method: .post, parameters: parameters, headers: ["Referer":LoginURL.matrixcode]).responseString(completionHandler: {
            response in
            switch response.result {
            case .success(let html):
                if html.contains(ConfirmString.success){
                    print("Matrixcode OK")
                    completion(true,html)
                }else{
                    print("Matrixcode NG")
                    self.status = .matrixcodeNG
                    completion(false,html)
                }
            case .failure(let error):
                print("Matrixcode NetworkError:\(error)")
                self.status = .networkError
                completion(false,"")
            }
        })
    }
    
    fileprivate func login_OCWi(completion:@escaping ((Bool)->())){
        Alamofire.request(LoginURL.ocwi).responseString(encoding:String.Encoding.utf8,completionHandler: {
            response in
            switch response.result {
            case .success(let html):
                print("OCWi OK")
                self.ocwiHtml = html
                self.status = .success
                self.ocwiCalendarURL = self.getOCWiCalendarURL(html)
                self.assignments = Assignment.arr(html)
                completion(true)
            case .failure(let error):
                print("OCWi NG:\(error)")
                self.status = .networkError
                completion(false)
            }
        })
    }
    
    fileprivate func getOCWiCalendarURL(_ ocwiHTML:String)->String?{
        let html = ocwiHTML.replacingOccurrences(of: "&amp;", with: "&")
        if let calenderID = html.match(RegexpPattern.calender){
            return LoginURL.calender+calenderID
        }
        
        return nil
    }
    
    
    fileprivate func postNotification(_ loginNotification : LoginNotification){
        NotificationCenter.default.post(name: Notification.Name(rawValue: loginNotification.rawValue), object: nil, userInfo: nil)
    }
}
