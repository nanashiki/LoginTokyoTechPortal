//
//  JSON.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/06.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

class JSON: NSObject {
    static func arrayFromString(aString:String?)->[String]?{
        if let str = aString{
            do{
                return try NSJSONSerialization.JSONObjectWithData(str.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as? [String]
            }catch{
                return nil
            }
        }else{
            return nil
        }
    }
    
    static func stringFromArray(aArray : [String])->String?{
        do{
            return try NSString(data: NSJSONSerialization.dataWithJSONObject(aArray, options: .PrettyPrinted), encoding: NSUTF8StringEncoding) as? String
        }catch{
            return nil
        }
        
    }
}
