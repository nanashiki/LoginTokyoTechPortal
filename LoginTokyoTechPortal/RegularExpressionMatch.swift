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
            for i in 0 ..< dat.count {
                if let res : NSTextCheckingResult = dat[i]{
                    var datss :[String] = []
                    for j in 1 ..< res.numberOfRanges {
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
    
    static func matcheInString(string : NSString , pattern : NSString)->String?{
        do{
            
            let dat = try NSRegularExpression(pattern: pattern as String, options: .CaseInsensitive).matchesInString(string as String, options: .ReportProgress, range: NSMakeRange(0,string.length))
            
            if dat.count == 0 {
                return nil
            }
            
            guard let res : NSTextCheckingResult = dat[0] else{
                return nil
            }
            
            return string.substringWithRange(res.rangeAtIndex(1))
        }catch{
            return nil
        }
    }
}
