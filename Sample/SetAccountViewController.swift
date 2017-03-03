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

enum ACPASSConfirmationError : Error{
    case noError
    case accountContainSpace
    case accountIllegalString
    case passwordIllegalString
    case unknown
}

class SetAccountViewController: UIViewController {
    var accountTF : UITextField?
    var passwordTF : UITextField?
    let login = Login.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell
        
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "Account", for: indexPath)
            accountTF = cell.viewWithTag(200) as? UITextField;
            accountTF?.text = login.account.username
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "Password", for: indexPath)
            passwordTF = cell.viewWithTag(200) as? UITextField;
        }
        
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        
    }

    @IBAction func saveBtnAction(_ sender: AnyObject) {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show(withStatus: "認証中")
        tfConfirmation({
            error,account,password in
            print("Account and Password is \(error)")
            switch error {
            case .noError:
                self.login.check(account: account, password: password,completion: {
                    success in
                    if success {
                        self.login.account.username = account
                        let ud = UserDefaults.standard
                        ud.set(account, forKey: "Account")
                        ud.synchronize()
                        
                        self.login.account.password = password
                        Keychain(service:"com.dotApp.LoginTokyoTechPortal.password")[account] = password
                    }
                    
                    DispatchQueue.main.async(execute: {
                        if success {
                            SVProgressHUD.showSuccess(withStatus: "保存完了")
                        }else{
                            SVProgressHUD.showError(withStatus: "認証失敗")
                        }
                    })
                })
            case .accountContainSpace:
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.showError(withStatus: "\(error)")
                })
            case .accountIllegalString:
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.showError(withStatus: "\(error)")
                })
            case .passwordIllegalString:
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.showError(withStatus: "\(error)")
                })
            default:
                DispatchQueue.main.async(execute: {
                    SVProgressHUD.showError(withStatus: "不明なエラー")
                })
            }
        })
    }
    
    func tfConfirmation(_ completed:((ACPASSConfirmationError,String,String)->())){
        if var account = accountTF?.text{
            if let password = passwordTF?.text{
                if account.characters.count == 0 || account.contains(" "){
                    completed(.accountContainSpace,"","")
                    return
                }
                
                account = account.replacingOccurrences(of: "b", with: "B")
                account = account.replacingOccurrences(of: "m", with: "M")
                
                if !account.contains("B") && !account.contains("M"){
                    completed(.accountIllegalString,"","")
                    return
                }
                
                if password.characters.count < 8 || password.contains(" "){
                    completed(.passwordIllegalString,"","")
                    return
                }
                
                completed(.noError,account,password)
                return
            }
        }
        
        completed(.unknown,"","")
        
    }

    @IBAction func BackBtnAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
