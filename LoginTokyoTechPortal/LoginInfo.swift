//
//  LoginInfo.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/14.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

public class LoginInfo: NSObject {
    public var account:String
    public var password:String
    public var matrixcode:[String]
    
    public init(account account_:String?,password password_:String?,matrixcode matrixcode_:[String]?) {
        if let account = account_{
            self.account = account
        }else{
            self.account = ""
        }
        
        if let password = password_{
            self.password = password
        }else{
            self.password = ""
        }
        
        if let matrixcode = matrixcode_{
            self.matrixcode = matrixcode
        }else{
            self.matrixcode = [String](count:70, repeatedValue: "")
        }
    }
}
