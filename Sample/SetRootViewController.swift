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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = dataList[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch indexPath.row{
        case 0:
            self.performSegueWithIdentifier("Account", sender: nil)
        case 1:
            self.performSegueWithIdentifier("Matrixcode", sender: nil)
        default:
            break;
        }
        
    }

    @IBAction func backBtnAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:{
            UIApplication.sharedApplication().statusBarHidden = true
        })
    }
}
