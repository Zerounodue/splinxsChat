//
//  broadcastTableViewController.swift
//  splinxsChat
//
//  Created by Elia Kocher on 17.05.16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit
import CoreData

class broadcastTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var sendButton: UIButton!

     
    @IBOutlet weak var isTypingLable: UILabel!
     
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var conBottomEditor: NSLayoutConstraint!
    

    var nickname: String!
    var persistentChatMessages = [NSManagedObject]()
    //var chatMessages = [[String: AnyObject]]()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(broadcastTableViewController.handleUserTypingNotification(_:)), name: "userTypingNotification", object: nil)
        // Do any additional setup after loading the view.uitextviewtextdidchangenotification

        
        
        //observe when keyboard is shown or hidden in order to adapt the layout
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(broadcastTableViewController.handleKeyboardDidShowNotification(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(broadcastTableViewController.handleKeyboardDidHideNotification(_:)), name: UIKeyboardDidHideNotification, object: nil)
        
        //hide keyboard when swiping down
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(broadcastTableViewController.dismissKeyboard))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
        persistentChatMessages.removeAll()
        loadPersistentMessages()
        socketIOcontroller.sharedInstance.getChatMessage { (messageInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                //add the new recived text in the chatMessages array
                //self.chatMessages.append(messageInfo)
                //
                self.savePersistentMessage(messageInfo)
     
                
                //reload the table in orde to display the new text
                self.chatTableView.reloadData()
                self.scrollToBottom()
            })
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //sendButton.backgroundColor? = UIColor.greenColor()
        //sendButton.tintColor? = UIColor.whiteColor()
        configureTableView()
        //configureNewsBannerLabel()
        configureOtherUserActivityLabel()
        
        messageTextView.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.scrollToBottom()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: IBAction Methods
    
    @IBAction func sendMessage(sender: AnyObject) {
        //check if text is not empty
        if messageTextView.text.characters.count > 0 {
            socketIOcontroller.sharedInstance.sendMessage(messageTextView.text!, withNickname: nickname)
            //clear the textfield
            messageTextView.text = ""
            //hide keyboard
            messageTextView.resignFirstResponder()
        }
    }
    
    // MARK: Custom Methods
    
    func configureTableView() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.registerNib(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        chatTableView.estimatedRowHeight = 90.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func configureOtherUserActivityLabel() {
        isTypingLable.hidden = true
        isTypingLable.text = ""
    }
    
    //move the view containing the textview and send button up when keyboard is shown
    func handleKeyboardDidShowNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                conBottomEditor.constant = keyboardFrame.size.height
                view.layoutIfNeeded()
            }
        }
    }
    
    //move the view containing the textview and send button down when keyboard is hidden
    func handleKeyboardDidHideNotification(notification: NSNotification) {
        conBottomEditor.constant = 0
        view.layoutIfNeeded()
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.persistentChatMessages.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.persistentChatMessages.count - 1, inSection: 0)
                self.chatTableView.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    func dismissKeyboard() {
        if messageTextView.isFirstResponder() {
            messageTextView.resignFirstResponder()
            socketIOcontroller.sharedInstance.sendStopTypingMessage(nickname)
        }
    }
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persistentChatMessages.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellChat", forIndexPath: indexPath) as! ChatCell
        //cell.removeConstraint(cell.leftConstraint)
        //cell.removeConstraint(cell.rightConstraint)

        let currentChatMessage = persistentChatMessages[indexPath.row]
        let senderNickname  = currentChatMessage.valueForKey("nickname") as? String
        let message  = currentChatMessage.valueForKey("message") as? String
        let messageDate  = currentChatMessage.valueForKey("dateTime") as? String
        let isLocal  = currentChatMessage.valueForKey("isLocal") as! Bool
        
        //let senderNickname = currentChatMessage["nickname"] as! String
        //let message = currentChatMessage["message"] as! String
        //let messageDate = currentChatMessage["date"] as! String
        
        //local message --> align to right
        //if senderNickname == nickname {
        if (isLocal){
            /*
            let trailingContraint = NSLayoutConstraint(item: cell,
                                                       attribute: NSLayoutAttribute.Trailing,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: cell.bubble,
                                                       attribute: NSLayoutAttribute.Trailing,
                                                       multiplier: 1.0,
                                                       constant: 10)
            cell.addConstraint(trailingContraint)
    */
            
            //cell.rightConstraint.constant = 10
            cell.leftConstraint.priority = 250
            cell.rightConstraint.priority = 750
            cell.bubble.backgroundColor = UIColor.init(red: 40.0/255, green: 178.0/255, blue: 148.0/255, alpha: 1)

        }
        else{
            /*
            let leadingContraint = NSLayoutConstraint(item: cell.bubble,
                                                      attribute: NSLayoutAttribute.Leading,
                                                      relatedBy: NSLayoutRelation.Equal,
                                                      toItem: cell,
                                                      attribute: NSLayoutAttribute.Leading,
                                                      multiplier: 1.0,
                                                      constant: 10)
            cell.addConstraint(leadingContraint)
            */
            //cell.removeConstraint(cell.rightConstraint)
            //cell.leftConstraint.constant = 10
            //cell.rightConstraint.constant = 50
            cell.leftConstraint.priority = 750
            cell.rightConstraint.priority = 250
            cell.bubble.backgroundColor = UIColor.init(red: 49.0/255, green: 189.0/255, blue: 199.0/255, alpha: 1.0)
            //
        }
        //cell.widthConstraint.constant = 200
        cell.nicknameLable.text = senderNickname! + ":"
        cell.messageLable.text = message
        cell.timeLable.text = messageDate
        
        //cell.lblChatMessage.text = message
        //cell.lblMessageDetails.text = "by \(senderNickname.uppercaseString) @ \(messageDate)"
        
        //cell.lblChatMessage.textColor = UIColor.darkGrayColor()
        cell.setNeedsLayout()
        
        return cell
    }
    
    
    // MARK: UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        socketIOcontroller.sharedInstance.sendStartTypingMessage(nickname)
        return true
    }
    
    
    // MARK: UIGestureRecognizerDelegate Methods
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    //show and hide "isTyping" message
    func handleUserTypingNotification(notification: NSNotification) {
        if let typingUsersDictionary = notification.object as? [String: AnyObject] {
            var names = ""
            var totalTypingUsers = 0
            for (typingUser, _) in typingUsersDictionary {
                if typingUser != nickname {
                    names = (names == "") ? typingUser : "\(names), \(typingUser)"
                    totalTypingUsers += 1
                }
            }
            
            if totalTypingUsers > 0 {
                let verb = (totalTypingUsers == 1) ? "is" : "are"
                
                isTypingLable.text = "\(names) \(verb) typing..."
                isTypingLable.hidden = false
            }
            else {
                isTypingLable.hidden = true
            }
        }
        
    }
    
    func savePersistentMessage(messageInfo: [String: AnyObject]) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Message", inManagedObjectContext:managedContext)
        let message = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let nick = messageInfo["nickname"] as! String
        let mess = messageInfo["message"] as! String
        let dat = messageInfo["date"] as! String
        var isLocal:Bool
        if ( messageInfo["nickname"] as! String == self.nickname){
            isLocal=true
        }
        else{isLocal=false}
        //let isLocal = messageInfo["nickname"] as! String ? "Online" : "Offline"

        message.setValue(nick, forKey: "nickname")
        message.setValue(mess, forKey: "message")
        message.setValue(dat, forKey: "dateTime")
        message.setValue(isLocal, forKey: "isLocal")
        message.setValue("null", forKey: "room")
        
        do {
            //dont save it, it's saved in userTableViewController
            //try managedContext.save()
            persistentChatMessages.append(message)
        } /*catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
 */
    }
    

    
    func loadPersistentMessages(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Message")
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            
            persistentChatMessages = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
