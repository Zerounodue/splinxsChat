//
//  usersTableViewController.swift
//  splinxsChat
//
//  Created by Elia Kocher on 17.05.16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit

class usersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tblUserList: UITableView!
    var nickname: String!
    var users = [[String: AnyObject]]()
    var configurationOK = false
     
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
         
        //set username and get online users
        socketIOcontroller.sharedInstance.connectToServerWithNickname(nickname, completionHandler: { (userList) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if userList != nil {
                    
                    self.users = userList
                    /*
                    for u in 0...self.users.count-1 {
                        if (self.users[u]["nickname"] as? String == self.nickname){
                            self.users.removeAtIndex(u)
                        }
                    }
                    */
                    self.tblUserList.reloadData()
                    self.tblUserList.hidden = false
                }
            })
        })
        
        //replace back arrow with logout text and add action
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(usersTableViewController.back(_:)))
        newBackButton.tintColor = UIColor.init(red: 37.0/255, green: 133.0/255, blue: 196.0/255, alpha: 1)
        self.navigationItem.leftBarButtonItem = newBackButton;
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //add noridication observers when user connects or disconnects
        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(usersTableViewController.handleConnectedUserUpdateNotification(_:)), name: "userConnectedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(usersTableViewController.handleDisconnectedUserUpdateNotification(_:)), name: "userDisconnectedNotification", object: nil)
 */
    }
    
    
    func back(sender: UIBarButtonItem) {
        // Perform your custom actionsw
        socketIOcontroller.sharedInstance.exitChatWithNickname(nickname) { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.nickname = nil
                self.users.removeAll()
                self.tblUserList.hidden = true
                //TODO go back
                
            })
        }
        // Go back to the previous ViewController
        self.navigationController?.popViewControllerAnimated(true)
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellUser", forIndexPath: indexPath) as! UserCell
        
        //fill the cells with name, online status and colo for status
        cell.nicknameLable.text = users[indexPath.row]["nickname"] as? String
        //cell.onlineStatusImage.image = UIImage(named: "chatOn.png")
        cell.onlineStatusImage.image = (users[indexPath.row]["isConnected"] as! Bool) ? UIImage(named: "chatOn.png") : UIImage(named: "chatOff.png")

        //cell.onlineDot.backgroundColor  = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
        cell.statusLable?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        //messageDictionary["date"] = dataArray[2] as! String
        //cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
        //cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        //cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
        
        
        
        return cell
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }


    func configureTableView() {
        tblUserList.delegate = self
        tblUserList.dataSource = self
        tblUserList.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        tblUserList.hidden = true
        tblUserList.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "goToBroadcast" {
                let broadcastVC = segue.destinationViewController as! broadcastTableViewController
                broadcastVC.nickname = nickname
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow
        //let cell = tableView.dequeueReusableCellWithIdentifier("idCellChat", forIndexPath: indexPath) as! ChatCell
        let currentCell = tableView.cellForRowAtIndexPath(indexPath!) as! UserCell
        //print(currentCell.nicknameLable.text!)
        //let loggedInView: UserViewController = storyboard.instantiateViewControllerWithIdentifier("loggedInView") as UserViewController
        //let priavteVC = segue.destinationViewController as! broadcastTableViewController
        //broadcastVC.nickname = nickname
        //let priavteVC = broadcastTableViewController()
        //priavteVC.nickname = nickname
        //var rootViewController = self.window!.rootViewController as UINavigationController
        if(currentCell.nicknameLable.text! == nickname){
            let alertController = UIAlertController(title: "WTF", message:
                "You want to chat with yourself?", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if(currentCell.statusLable.text! == "Offline"){
            let alertController = UIAlertController(title: "Hey!", message:
                "He is offline, don't bore him please", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else{
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let privateVC = mainStoryboard.instantiateViewControllerWithIdentifier("privateVC") as! privateTableViewController
            privateVC.nickname = nickname
            privateVC.destinationNickname=currentCell.nicknameLable.text!
            
            self.navigationController?.pushViewController(privateVC, animated: true)
        }
    }
    
    /*
    func handleConnectedUserUpdateNotification(notification: NSNotification) {
        let connectedUserInfo = notification.object as! [String: AnyObject]
        let connectedUserNickname = connectedUserInfo["nickname"] as? String
        //lblNewsBanner.text = "User \(connectedUserNickname!.uppercaseString) was just connected."
        //showBannerLabelAnimated()
    }
    func handleDisconnectedUserUpdateNotification(notification: NSNotification) {
        let disconnectedUserNickname = notification.object as! String
        //lblNewsBanner.text = "User \(disconnectedUserNickname.uppercaseString) has left."
        //showBannerLabelAnimated()
    }
 */
 
    
   
}
