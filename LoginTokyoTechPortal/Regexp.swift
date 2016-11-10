//
//  Regexp.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import Foundation

public extension String {
    func match(_ pattern : String,options:NSRegularExpression.Options = []) -> String?{
        return Regexp(pattern,options:options).match(self)
    }
    
    func matches(_ pattern : String,options:NSRegularExpression.Options = []) -> [[String]]?{
        return Regexp(pattern,options:options).matches(self)
    }
}

struct Regexp{
    let pattern : String
    var options : NSRegularExpression.Options
    
    init(_ pattern:String,options:NSRegularExpression.Options = []) {
        self.pattern = pattern
        self.options = options
    }
    
    func matches(_ string : String)->[[String]]?{
        do{
            let results = try NSRegularExpression(pattern: pattern, options: options).matches(in: string, options: .reportProgress, range: NSMakeRange(0,string.characters.count))
            var dats : [[String]] = [];
            for result in results {
                var datss :[String] = []
                for j in 1 ..< result.numberOfRanges {
                    datss.append((string as NSString).substring(with: result.rangeAt(j)))
                }
                dats += [datss]
            }
            return dats
            
        }catch{
           return nil
        }
    }
    
    func match(_ string : String)->String?{
        do{
            let dat = try NSRegularExpression(pattern: pattern, options: options).matches(in: string, options: .reportProgress, range: NSMakeRange(0,string.characters.count))
            
            if dat.count == 0 {
                return nil
            }
            
            return (string as NSString).substring(with: dat[0].rangeAt(1))
        }catch{
            return nil
        }
    }
}
