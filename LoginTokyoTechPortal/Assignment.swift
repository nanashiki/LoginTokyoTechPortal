//
//  Assignment.swift
//  LoginTokyoTechPortal
//
//  Created by nana_dotApp on 2016/04/09.
//  Copyright © 2016年 nanashiki. All rights reserved.
//

import Foundation

public extension Date{
    static func date(string string_:AnyObject?)->Date?{
        if let string = string_ as? String{
            let date_formatter = DateFormatter()
            date_formatter.locale = Locale(identifier: "ja")
            date_formatter.dateFormat = "yyyy/MM/dd HH:mm"
            return date_formatter.date(from: string)
        }else{
            return nil
        }
        
    }
}

fileprivate struct LoginURL {
    static let ocwi = "https://secure.ocw.titech.ac.jp/ocwi/index.php"
}

fileprivate struct RegexpPattern {
    static let assignments = "\\{\n([^}]+)\n\\}"
    static let time_str = "<td>(.+)</td>"
    static let class_info = "<td><a href=\"(.+)\">(.+)</a></td>"
    static let assignment_info = "<td><a href=\"(.+)\">(.+)</a></td>"
}

open class Assignment: NSObject {
    open let name:String
    open let time:Date
    open let url:URL
    open let class_name:String
    open let class_url:URL
    
    init(name:String,time:Date,url:URL,class_name:String,class_url:URL) {
        self.name = name
        self.time = time
        self.url = url
        self.class_name = class_name
        self.class_url = class_url
    }
    
    static func arr(_ aString:String)->[Assignment]{
        var html = aString.replacingOccurrences(of: "<tr>", with: "{")
        html = html.replacingOccurrences(of: "</tr>", with: "}")
        
        var arr = [Assignment]()
        
        if let assignments = html.matches(RegexpPattern.assignments){
            for assignment in assignments {
                let values = assignment[0].components(separatedBy: "\n")
                
                if values.count != 3{
                    continue
                }
                guard let time_str = values[0].match(RegexpPattern.time_str) else{
                    continue
                }
                
                guard let time = Date.date(string: time_str as AnyObject?)else{
                    continue
                }
                
                guard let class_info = values[1].matches(RegexpPattern.class_info) else{
                    continue
                }
                
                if class_info.count != 1{
                    continue
                }
                
                if class_info[0].count != 2{
                    continue
                }
                
                guard let class_url = URL(string: LoginURL.ocwi+class_info[0][0])else{
                    continue
                }
                
                guard let assignment_info = values[2].matches(RegexpPattern.assignment_info) else{
                    continue
                }
                
                if assignment_info.count != 1{
                    continue
                }
                
                if assignment_info[0].count != 2{
                    continue
                }
                
                guard let url = URL(string: LoginURL.ocwi+assignment_info[0][0])else{
                    continue
                }
                
                
                arr += [Assignment(name:assignment_info[0][1],time:time,url:url,class_name:class_info[0][1],class_url:class_url)]
                
            }
        }
        
        return arr
    }
}
