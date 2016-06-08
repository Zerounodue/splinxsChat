//
//  startViewController.swift
//  splinxsChat
//
//  Created by Elia Kocher on 17.05.16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit

class startViewController: UIViewController {
    var isConnected = false
    let localIP = "http://192.168.178.36:3000"
    let splinxsIP = "http://147.87.116.139:3000"
    @IBOutlet weak var nicknameTextFiel: UITextField!
    @IBOutlet weak var ipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var statusLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
   
    
    
    override func viewDidAppear(animated: Bool) {
        self.statusLable.text = "Offline"
        socketIOcontroller.sharedInstance.isConnectionEstablished{ (isConnected) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isConnected = isConnected
                self.statusLable.text = isConnected ? "Online" : "Offline"
            })
        }
    }
    
    @IBAction func infoAction(sender: AnyObject) {
        let alertController = UIAlertController(title: "Info", message:
            "The local IP is: " + localIP + " consider to chang it in order to mach your PC's IP \n the Splinxs server is avaliable only if you are connected to the BFH network", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connectAction(sender: AnyObject) {
        //check if it's connected to socket.io
        if !isConnected {
            let alertController = UIAlertController(title: "Attention", message:
                "You are not connected, maybe the server is down. \n I try to reconnect now.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        //check if the text is not empty
        else if nicknameTextFiel.text?.characters.count == 0 {
            let alertController = UIAlertController(title: "Attention", message:
                "You must enter a nickname", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        else {
            //self.nickname = nicknameTextFiel.text
            
            self.performSegueWithIdentifier("goToUsers", sender: nicknameTextFiel.text)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "goToUsers" {
                let usersTableVC = segue.destinationViewController as! usersTableViewController
                usersTableVC.nickname = nicknameTextFiel.text
            }
        }
    }
    @IBAction func ipChanged(sender: AnyObject) {
        isConnected = false
        self.statusLable.text = "Offline"
        let socketIP = (ipSegmentedControl.selectedSegmentIndex != 0)  ?  splinxsIP : localIP
        socketIOcontroller.sharedInstance.closeConnection()
        socketIOcontroller.sharedInstance.setSocketIP(socketIP)
        socketIOcontroller.sharedInstance.isConnectionEstablished{ (isConnected) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isConnected = isConnected
                self.statusLable.text = isConnected ? "Online" : "Offline"
            })
        }
        socketIOcontroller.sharedInstance.establishConnection()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
