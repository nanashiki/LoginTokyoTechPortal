//
//  RegularExpressionMatch.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

class RegularExpressionMatch: NSObject {
     static func matchesInString(string : NSString , pattern : NSString)->[[String]]?{
        do{
            let dat = try NSRegularExpression(pattern: pattern as String, options: .CaseInsensitive).matchesInString(string as String, options: .ReportProgress, range: NSMakeRange(0,string.length))
            var dats : [[String]] = [];
            for var i = 0; i < dat.count; i++ {
                if let res : NSTextCheckingResult = dat[i]{
                    var datss :[String] = []
                    for var j = 1; j < res.numberOfRanges; j++ {
                        datss.append(string.substringWithRange(res.rangeAtIndex(j)))
                    }
                    dats += [datss]
                }
            }
            return dats
            
        }catch{
           return nil
        }
    }
}
