//
//  HTTPConnection.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

class HTTPConnection: NSObject {
    static func getStringFromGETRequest(urlString_:String?,timeout timeout_:NSTimeInterval? = nil,completion:(String?)->Void){
        guard let urlString = urlString_ else{
            completion(nil)
            return
        }
        
        guard let url = NSURL(string: urlString) else{
            completion(nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        if let timeout = timeout_{
            request.timeoutInterval = timeout
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            data_, response, error in
            if let data = data_{
                let result = String(data: data, encoding: NSUTF8StringEncoding)
                completion(result)
            }else{
                completion(nil)
            }
        })
        task.resume()
    }
    
    static func getStringFromPOSTRequest(url urlString_:String?,post:String,referer:String,timeout timeout_:NSTimeInterval? = nil,completion:(String?)->Void){
        guard let urlString = urlString_ else{
            completion(nil)
            return
        }
        
        guard let url = NSURL(string: urlString) else{
            completion(nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = post.dataUsingEncoding(NSUTF8StringEncoding)
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("https://portal.nap.gsic.titech.ac.jp", forHTTPHeaderField: "Origin")
        request.setValue("User-Agent", forHTTPHeaderField: "Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B137 Safari/601.1")
        request.setValue(referer, forHTTPHeaderField: "Referer")
        
        if let timeout = timeout_{
            request.timeoutInterval = timeout
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            data_, response, error in
            if let data = data_{
                let result = String(data: data, encoding: NSUTF8StringEncoding)
                completion(result)
            }else{
                completion(nil)
            }
        })
        task.resume()
    }
    
    
    static func getPOSTStringFromHTML(var html:String)->String{
        html = html.stringByReplacingOccurrencesOfString("<!--<input", withString: "")
        html = html.stringByReplacingOccurrencesOfString("'", withString: "\"")
        guard let result1 = RegularExpressionMatch.matchesInString(html,pattern: "<input ([^<]+)>") else{return ""}
        var postStr = ""
        
        for (var i = 0; i < result1.count ;i++){
            guard let name = RegularExpressionMatch.matchesInString(result1[i][0],pattern: "name=\"([^\"]*)\"") else{continue}
            guard let value = RegularExpressionMatch.matchesInString(result1[i][0],pattern: "value=\"([^\"]*)\"") else{continue}
            if value.count != 0{
                postStr += "\(name[0][0])=\(value[0][0])"
            }else{
                postStr += "\(name[0][0])="
            }
            
            if i != result1.count-1{
                postStr += "&"
            }
        }
        
        
        return postStr
    }
}
