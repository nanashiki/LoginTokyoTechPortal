//
//  SetMatrixcodeViewController.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/11/06.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit
import KeychainAccess
import SVProgressHUD
import LoginTokyoTechPortal

class SetMatrixcodeViewController: UIViewController,UITextFieldDelegate {
    private var matrixcode = [String](count: 70, repeatedValue: "")
    private let login = Login.sharedInstance
    private let alphabet = ["A","B","C","D","E","F","G","H","I","J"]
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matrixcode = login.loginInfo.matrixcode
        
        let longPressGesture  = UILongPressGestureRecognizer(target: self, action: "viewLongPress:")
        longPressGesture.minimumPressDuration = 2.0
        view.addGestureRecognizer(longPressGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        
        if let matrixL = cell.viewWithTag(100) as? UILabel{
            matrixL.text = "\(alphabet[indexPath.section])\(indexPath.row+1)"
        }
        
        if let matrixcodeTF = cell.viewWithTag(200) as? UITextFieldPlus{
            matrixcodeTF.delegate = self
            matrixcodeTF.indexPath = indexPath
            matrixcodeTF.autocapitalizationType = .AllCharacters
            matrixcodeTF.placeholder = "\(alphabet[indexPath.section])\(indexPath.row+1)"
            matrixcodeTF.text = matrixcode[indexPath.section*7+indexPath.row]
            
            matrixcodeTF.addTarget(self, action: "matrixcodeTFEditingChanged:", forControlEvents: .EditingChanged)
        }
        
        return cell
    }
    
    func matrixcodeTFEditingChanged(sender : UITextFieldPlus){
        if let text = sender.text{
            matrixcode[sender.indexPath.section*7+sender.indexPath.row] = text
            if text.characters.count == 1{
                performSelector("moveTF:", withObject: sender.indexPath, afterDelay: 0.01)
            }
        }
    }
    
    func moveTF(indexPath : NSIndexPath){
        let nextIndex = indexPath.section*7+indexPath.row+1
        let cell = tv.cellForRowAtIndexPath(NSIndexPath(forRow: nextIndex%7, inSection: nextIndex/7))
        if let tf = cell?.viewWithTag(200) as? UITextFieldPlus{
            tf.becomeFirstResponder()
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.containsString(" "){
            return false
        }
        
        if let text = (textField.text! as NSString).mutableCopy() as? NSMutableString{
            text.replaceCharactersInRange(range, withString: string)
            return text.length <= 1
        }
        
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let textFieldRect = tv.convertRect(textField.bounds, fromView: textField)
        var scrollPoint = CGPointMake(0.0,-64.0)
        
        if textFieldRect.origin.y >= 120.0 {
            scrollPoint = CGPointMake(0.0,textFieldRect.origin.y-144.0)
        }
        
        tv.setContentOffset(scrollPoint, animated: true)
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func viewLongPress(sender:UILongPressGestureRecognizer){
        if sender.state == .Began{
            let alert = UIAlertController(title: "マトリクスコードインポート", message: "マトリクスコードをインポートしますか？", preferredStyle: .Alert)
            let okBtn = UIAlertAction(title: "OK", style: .Default, handler: {
                action in
                let json = UIPasteboard.generalPasteboard().valueForPasteboardType("public.utf8-plain-text") as! String
                if let arr = JSON.arrayFromString(json){
                    if arr.count == 70{
                        self.matrixcode = arr
                        self.tv.reloadData()
                    }else{
                        let alert = UIAlertController(title: "エラー", message: "不正な値です", preferredStyle: .Alert)
                        let okBtn = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alert.addAction(okBtn)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            })
            let cancelBtn = UIAlertAction(title: "cancel", style: .Cancel, handler: nil)
            alert.addAction(okBtn)
            alert.addAction(cancelBtn)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveBtnAction(sender: AnyObject) {
        save_Matrixcode()
    }
    
    func save_Matrixcode(){
        view.endEditing(true)
        SVProgressHUD.showWithStatus("認証中", maskType: .Clear)
        if tfConfirmation(){
            login.check(matrixcode: self.matrixcode, completion: {
                success in
                if success{
                    self.login.loginInfo.matrixcode = self.matrixcode
                    Keychain(service:"com.dotApp.LoginTokyoTechPortal.MatrixCode")[self.login.loginInfo.account] = JSON.stringFromArray(self.matrixcode)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    if success {
                        SVProgressHUD.showSuccessWithStatus("保存完了", maskType: .Clear)
                    }else{
                        SVProgressHUD.showErrorWithStatus("認証失敗", maskType: .Clear)
                    }
                })
            })
            
        }else{
            print("error")
            SVProgressHUD.showErrorWithStatus("空白があります",maskType: .Clear)
        }
    }
    
    
    func tfConfirmation()->Bool{
        for code in matrixcode{
            if code.characters.count == 0 || code.containsString(" "){
               return false
            }
        }
        
        return true
    }
    
    
}
