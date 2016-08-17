//
//  Assignment.swift
//  LoginTokyoTechPortal
//
//  Created by nana_dotApp on 2016/04/09.
//  Copyright © 2016年 nanashiki. All rights reserved.
//

import UIKit

public extension NSDate{
    static func date(string string_:AnyObject?)->NSDate?{
        if let string = string_ as? String{
            let date_formatter = NSDateFormatter()
            date_formatter.locale = NSLocale(localeIdentifier: "ja")
            date_formatter.dateFormat = "yyyy/MM/dd HH:mm"
            return date_formatter.dateFromString(string)
        }else{
            return nil
        }
        
    }
}

public class Assignment: NSObject {
    public let name:String
    public let time:NSDate
    public let url:NSURL
    public let class_name:String
    public let class_url:NSURL
    
    init(name:String,time:NSDate,url:NSURL,class_name:String,class_url:NSURL) {
        self.name = name
        self.time = time
        self.url = url
        self.class_name = class_name
        self.class_url = class_url
    }
    
    static func arr(aString:String)->[Assignment]{
        var html = aString.stringByReplacingOccurrencesOfString("<tr>", withString: "{")
        html = html.stringByReplacingOccurrencesOfString("</tr>", withString: "}")
        
        var arr = [Assignment]()
        
        if let assignments = RegularExpressionMatch.matchesInString(html, pattern: "\\{\n([^}]+)\n\\}"){
            for assignment in assignments {
                let values = assignment[0].componentsSeparatedByString("\n")
                
                if values.count != 3{
                    continue
                }
                guard let time_str = RegularExpressionMatch.matcheInString(values[0], pattern: "<td>(.+)</td>") else{
                    
                    continue
                }
                
                guard let time = NSDate.date(string: time_str)else{
                    continue
                }
                
                guard let class_info = RegularExpressionMatch.matchesInString(values[1], pattern: "<td><a href=\"(.+)\">(.+)</a></td>") else{
                    continue
                }
                
                if class_info.count != 1{
                    continue
                }
                
                if class_info[0].count != 2{
                    continue
                }
                
                guard let class_url = NSURL(string: "https://secure.ocw.titech.ac.jp/ocwi/index.php"+class_info[0][0])else{
                    continue
                }
                
                guard let assignment_info = RegularExpressionMatch.matchesInString(values[2], pattern: "<td><a href=\"(.+)\">(.+)</a></td>") else{
                    continue
                }
                
                if assignment_info.count != 1{
                    continue
                }
                
                if assignment_info[0].count != 2{
                    continue
                }
                
                guard let url = NSURL(string: "https://secure.ocw.titech.ac.jp/ocwi/index.php"+assignment_info[0][0])else{
                    continue
                }
                
                
                arr += [Assignment(name:assignment_info[0][1],time:time,url:url,class_name:class_info[0][1],class_url:class_url)]
                
            }
        }
        
        return arr
    }
}
