//
//  JSON.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/06.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

class JSON: NSObject {
    static func arrayFromString(_ aString:String?)->[String]?{
        if let str = aString{
            do{
                return try JSONSerialization.jsonObject(with: str.data(using: String.Encoding.utf8) ?? Data(), options: .allowFragments) as? [String]
            }catch{
                return nil
            }
        }else{
            return nil
        }
    }
    
    static func stringFromArray(_ aArray : [String])->String?{
        do{
            return try NSString(data: JSONSerialization.data(withJSONObject: aArray, options: .prettyPrinted), encoding: String.Encoding.utf8.rawValue) as String?
        }catch{
            return nil
        }
        
    }
}
