//
//  SetAccountViewController.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit
import KeychainAccess
import SVProgressHUD
import LoginTokyoTechPortal

enum ACPASSConfirmationError : ErrorType{
    case NoError
    case AccountContainSpace
    case AccountIllegalString
    case PasswordIllegalString
    case Unknown
}

class SetAccountViewController: UIViewController {
    var accountTF : UITextField?
    var passwordTF : UITextField?
    let login = Login.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCellWithIdentifier("Account", forIndexPath: indexPath)
            accountTF = cell.viewWithTag(200) as? UITextField;
            accountTF?.text = login.loginInfo.account
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("Password", forIndexPath: indexPath)
            passwordTF = cell.viewWithTag(200) as? UITextField;
        }
        
        cell.selectionStyle = .None
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }

    @IBAction func saveBtnAction(sender: AnyObject) {
        SVProgressHUD.setDefaultMaskType(.Clear)
        SVProgressHUD.showWithStatus("認証中")
        tfConfirmation({
            error,account,password in
            print("Account and Password is \(error)")
            switch error {
            case .NoError:
                self.login.check(account: account, password: password,completion: {
                    success in
                    if success {
                        self.login.loginInfo.account = account
                        let ud = NSUserDefaults.standardUserDefaults()
                        ud.setObject(account, forKey: "Account")
                        ud.synchronize()
                        
                        self.login.loginInfo.password = password
                        Keychain(service:"com.dotApp.LoginTokyoTechPortal.password")[account] = password
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if success {
                            SVProgressHUD.showSuccessWithStatus("保存完了")
                        }else{
                            SVProgressHUD.showErrorWithStatus("認証失敗")
                        }
                    })
                })
            case .AccountContainSpace:
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.showErrorWithStatus("\(error)")
                })
            case .AccountIllegalString:
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.showErrorWithStatus("\(error)")
                })
            case .PasswordIllegalString:
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.showErrorWithStatus("\(error)")
                })
            default:
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.showErrorWithStatus("不明なエラー")
                })
            }
        })
    }
    
    func tfConfirmation(completed:((ACPASSConfirmationError,String,String)->())){
        if var account = accountTF?.text{
            if let password = passwordTF?.text{
                if account.characters.count == 0 || account.containsString(" "){
                    completed(.AccountContainSpace,"","")
                    return
                }
                
                account = account.stringByReplacingOccurrencesOfString("b", withString: "B")
                account = account.stringByReplacingOccurrencesOfString("m", withString: "M")
                
                if !account.containsString("B") && !account.containsString("M"){
                    completed(.AccountIllegalString,"","")
                    return
                }
                
                if password.characters.count < 8 || password.containsString(" "){
                    completed(.PasswordIllegalString,"","")
                    return
                }
                
                completed(.NoError,account,password)
                return
            }
        }
        
        completed(.Unknown,"","")
        
    }

    @IBAction func BackBtnAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
