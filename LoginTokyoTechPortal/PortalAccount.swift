//
//  LoginInfo.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/14.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import Foundation

public struct PortalAccount {
    public var username:String
    public var password:String
    public var matrixcode:[String]
    
    public init(username:String?,password:String?,matrixcode:[String]?) {
        if let username = username{
            self.username = username
        }else{
            self.username = ""
        }
        
        if let password = password{
            self.password = password
        }else{
            self.password = ""
        }
        
        if let matrixcode = matrixcode{
            self.matrixcode = matrixcode
        }else{
            self.matrixcode = [String](repeating: "", count: 70)
        }
    }
}
