//
//  LoginTitanetWireless.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/11.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

public enum LoginTitanetWirelessStatus : Int{
    case logout
    case nowLogin
    case success
    case alreadySuccess
    case failure
    case noWiFi
    case othersWiFi
    case accountNotSet
    case unknownError
}

public enum FinishLoginTitanetWirelessNotification : String{
    case success = "LoginTitanetWirelessSuccess"
}

fileprivate struct LoginURL {
    static let post = "https://wlanauth.noc.titech.ac.jp/login.html"
}

fileprivate struct FormInputName {
    static let username = "username"
    static let password = "password"
}

fileprivate struct ConfirmString {
    static let success = "Login Successful"
    static let alreadyLogined = "techauth.html"
    static let failure = "techfailure.html"
}

open class LoginTitanetWireless: NSObject {
    //SharedInstance
    open static let sharedInstance = LoginTitanetWireless()
    
    //LoginInfo
    open var account = PortalAccount(username: nil, password: nil, matrixcode: nil)
    
    //Status
    open fileprivate (set) var status:LoginTitanetWirelessStatus = .logout
    
    var sessionManager : SessionManager
    
    override fileprivate init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        sessionManager = SessionManager(configuration: configuration)
    }
    
    open func start(completion:((LoginTitanetWirelessStatus)->())? = nil){
        status = .nowLogin
        sessionManager.request(LoginURL.post,
                               method: .post,
                               parameters: [FormInputName.username:account.username,
                                            FormInputName.password:account.password,
                                            "buttonClicked":"4",
                                            "redirect_url":"",
                                            "err_flag":"0",
                                            "Submit":"同意して利用",]
            ).responseString(completionHandler: {
                response in
                switch response.result {
                case .success(let html):
                    if html.contains(ConfirmString.success) {
                        self.status = .success
                    }else if html.contains(ConfirmString.alreadyLogined) {
                        self.status = .alreadySuccess
                    }else if html.contains(ConfirmString.failure){
                        self.status = .failure
                    }else{
                        self.status = .unknownError
                        print("Unknown Error")
                    }
                case .failure(let error):
                    print("Time out:\(error)")
                    self.status = .unknownError
                    break
                }
                
                if self.status == .success || self.status == .alreadySuccess {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: FinishLoginTitanetWirelessNotification.success.rawValue), object: nil, userInfo: nil)
                }
                
                completion?(self.status)
            }
        )
    }
    
}
