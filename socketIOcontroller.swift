//
//  socketIOcontroller.swift
//  splinxsChat
//
//  Created by Elia Kocher on 17.05.16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit

class socketIOcontroller: NSObject {
    //singleton
    static let sharedInstance = socketIOcontroller()
    
    override init() {
        super.init()
    } 
    //socketIO object 
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.178.36:3000")!)
    //var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://147.87.116.139:3000")!)
    
    func setSocketIP(ip:String){
        socket = SocketIOClient(socketURL: NSURL(string: ip)!)
    }
     
    //connect to the server
    func establishConnection() {
        print("Connecting...")
        socket.connect()
    }
    
    //disconnect from the server
    func closeConnection() {
        socket.disconnect()
    }
    
    //to set the nickname when connected
    func connectToServerWithNickname(nickname: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("connectUser", nickname)
        sendMessage("I i'm online now", withNickname: nickname)
        //get the list of user when the server update it
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
        //add socketIO messages listeners
        listenForOtherMessages()
    }
    
    //when the user press on the exit button it should disconnect and remove it from the list
    func exitChatWithNickname(nickname: String, completionHandler: () -> Void) {
        sendMessage("I'm offline now", withNickname: nickname)
        socket.emit("exitUser", nickname)
        completionHandler()
    }
    
    //send a message to the server (will be broadcasted)
    func sendMessage(message: String, withNickname nickname: String) {
        socket.emit("chatMessage", nickname, message)
    }
    //send a private message to the server
    func sendPrivateMessage(message: String, withNickname nickname: String, withDestinationNickname destinationNickname: String) {
        var room:String
        //the room is always the nicknames ordered alfabetically
        if(destinationNickname < nickname){
            room = destinationNickname +  nickname
        }
        else{
            room = nickname + destinationNickname
        }
        socket.emit("chatPrivateMessage", nickname, room, message)
    }
    
    //listen to "newChatMessage" in order to recive new messages
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    //listen to "newChatMessage" in order to recive new messages
    func getPrivateChatMessage(destinationNickname: String, nickname: String, completionHandler: (messageInfo: [String: AnyObject]) -> Void) {
        var room:String
        //the room is always the nicknames ordered alfabetically
        if(destinationNickname < nickname){
            room = destinationNickname +  nickname
        }
        else{
            room = nickname + destinationNickname
        }
        
        socket.on(room) { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["nickname"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    
    // listen to userConnectUpdate and userExitUpdate
    private func listenForOtherMessages() {
        //new user entered nickname
        /*
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            //self.sendMessage("User connected: ", withNickname: nickname)
            NSNotificationCenter.defaultCenter().postNotificationName("userConnectedNotification", object: dataArray[0] as! [String: AnyObject])
        }
        //user terminated the app or pressed exit
        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            //self.sendMessage("User disconnected: ", withNickname: nickname)
            NSNotificationCenter.defaultCenter().postNotificationName("userDisconnectedNotification", object: dataArray[0] as! String)
        }
 */
        socket.on("userTypingUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userTypingNotification", object: dataArray[0] as? [String: AnyObject])
        }
    }
    
    //start and stop typinf feature
    func sendStartTypingMessage(nickname: String) {
        socket.emit("startType", nickname)
    }
    func sendStopTypingMessage(nickname: String) {
        socket.emit("stopType", nickname)
    }
    
    //listen to "newChatMessage" in order to recive new messages
    func isConnectionEstablished(completionHandler: (isConnected: Bool) -> Void) {
        socket.on("connect") {data, ack in
            print("connected!")
            completionHandler(isConnected: true)
        }
    }
}
