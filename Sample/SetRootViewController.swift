//
//  SetRootViewController.swift
//  TitechApp_swift
//
//  Created by nana_dotApp on 2015/10/28.
//  Copyright © 2015年 nanashiki. All rights reserved.
//

import UIKit

class SetRootViewController: UIViewController {
    var dataList = ["Account Setting","Matrixcode Setting"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = dataList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath){
        switch indexPath.row{
        case 0:
            self.performSegue(withIdentifier: "Account", sender: nil)
        case 1:
            self.performSegue(withIdentifier: "Matrixcode", sender: nil)
        default:
            break;
        }
        
    }

    @IBAction func backBtnAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion:{
            UIApplication.shared.isStatusBarHidden = true
        })
    }
}
