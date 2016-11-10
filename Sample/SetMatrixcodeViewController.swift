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
    fileprivate var matrixcode = [String](repeating: "", count: 70)
    fileprivate let login = Login.sharedInstance
    fileprivate let alphabet = ["A","B","C","D","E","F","G","H","I","J"]
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matrixcode = login.account.matrixcode
        
        let longPressGesture  = UILongPressGestureRecognizer(target: self, action: #selector(SetMatrixcodeViewController.viewLongPress(_:)))
        longPressGesture.minimumPressDuration = 2.0
        view.addGestureRecognizer(longPressGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        
        if let matrixL = cell.viewWithTag(100) as? UILabel{
            matrixL.text = "\(alphabet[indexPath.section])\(indexPath.row+1)"
        }
        
        if let matrixcodeTF = cell.viewWithTag(200) as? UITextFieldPlus{
            matrixcodeTF.delegate = self
            matrixcodeTF.indexPath = indexPath
            matrixcodeTF.autocapitalizationType = .allCharacters
            matrixcodeTF.placeholder = "\(alphabet[indexPath.section])\(indexPath.row+1)"
            matrixcodeTF.text = matrixcode[indexPath.section*7+indexPath.row]
            
            matrixcodeTF.addTarget(self, action: #selector(SetMatrixcodeViewController.matrixcodeTFEditingChanged(_:)), for: .editingChanged)
        }
        
        return cell
    }
    
    func matrixcodeTFEditingChanged(_ sender : UITextFieldPlus){
        if let text = sender.text{
            matrixcode[sender.indexPath.section*7+sender.indexPath.row] = text
            if text.characters.count == 1{
                perform(#selector(SetMatrixcodeViewController.moveTF(_:)), with: sender.indexPath, afterDelay: 0.01)
            }
        }
    }
    
    func moveTF(_ indexPath : IndexPath){
        let nextIndex = indexPath.section*7+indexPath.row+1
        let cell = tv.cellForRow(at: IndexPath(row: nextIndex%7, section: nextIndex/7))
        if let tf = cell?.viewWithTag(200) as? UITextFieldPlus{
            tf.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.contains(" "){
            return false
        }
        
        if let text = (textField.text! as NSString).mutableCopy() as? NSMutableString{
            text.replaceCharacters(in: range, with: string)
            return text.length <= 1
        }
        
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let textFieldRect = tv.convert(textField.bounds, from: textField)
        var scrollPoint = CGPoint(x: 0.0,y: -64.0)
        
        if textFieldRect.origin.y >= 120.0 {
            scrollPoint = CGPoint(x: 0.0,y: textFieldRect.origin.y-144.0)
        }
        
        tv.setContentOffset(scrollPoint, animated: true)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func viewLongPress(_ sender:UILongPressGestureRecognizer){
        if sender.state == .began{
            let alert = UIAlertController(title: "マトリクスコードインポート", message: "マトリクスコードをインポートしますか？", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "OK", style: .default, handler: {
                action in
                let json = UIPasteboard.general.value(forPasteboardType: "public.utf8-plain-text") as! String
                if let arr = JSON.arrayFromString(json){
                    if arr.count == 70{
                        self.matrixcode = arr
                        self.tv.reloadData()
                    }else{
                        let alert = UIAlertController(title: "エラー", message: "不正な値です", preferredStyle: .alert)
                        let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okBtn)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            let cancelBtn = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
            alert.addAction(okBtn)
            alert.addAction(cancelBtn)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveBtnAction(_ sender: AnyObject) {
        save_Matrixcode()
    }
    
    func save_Matrixcode(){
        view.endEditing(true)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.show(withStatus: "認証中")
        if tfConfirmation(){
            login.check(matrixcode: self.matrixcode, completion: {
                success in
                if success{
                    self.login.account.matrixcode = self.matrixcode
                    Keychain(service:"com.dotApp.LoginTokyoTechPortal.MatrixCode")[self.login.account.username] = JSON.stringFromArray(self.matrixcode)
                }
                
                DispatchQueue.main.async(execute: {
                    if success {
                        SVProgressHUD.showSuccess(withStatus: "保存完了")
                    }else{
                        SVProgressHUD.showError(withStatus: "認証失敗")
                    }
                })
            })
            
        }else{
            print("error")
            SVProgressHUD.showError(withStatus: "空白があります")
        }
    }
    
    
    func tfConfirmation()->Bool{
        for code in matrixcode{
            if code.characters.count == 0 || code.contains(" "){
               return false
            }
        }
        
        return true
    }
    
    
}
