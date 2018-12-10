//
//  ViewController.swift
//  Smack-Chat App
//
//  Created by Ketan Choyal on 05/12/18.
//  Copyright © 2018 Ketan Choyal. All rights reserved.
//

import UIKit

class ChatVC: UIViewController {

    //IBOutlet
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var chatChannelLabel: UILabel!
    @IBOutlet weak var messageTxtBox: AttributedTextColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bindToKeyboard()
        
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action:  #selector(handleTap))
        view.addGestureRecognizer(tap)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChanged(_:)), name: NOTIF_USER_DATA_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTIF_CHANNEL_SELECTED, object: nil)
        
        if AuthService.instance.isLoggedin {
            AuthService.instance.findUserByEmail(completion: { (success) in
                NotificationCenter.default.post(name: NOTIF_USER_DATA_CHANGE, object: nil)
            })
        }
    }
    
    @objc func channelSelected(_ notif : Notification) {
        updateWithChannel()
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func updateWithChannel() {
        let chatLabel = MessageService.instance.selectedChannel?.channelTitle ?? ""
        chatChannelLabel.text = "#" + chatLabel
        getMessages()
    }
    
    @objc func userDataDidChanged(_ notif : Notification) {
        if AuthService.instance.isLoggedin {
            onLoginGetMessages()
        } else {
            chatChannelLabel.text = "Please Log in"
        }
    }
    @IBAction func msgSendPressed(_ sender: Any) {
        if AuthService.instance.isLoggedin {
            guard let channelId = MessageService.instance.selectedChannel?.id else { return }
            guard let messageBody = messageTxtBox.text else { return }
            
            SocketService.instance.addMessage(messageBody: messageBody, channelId: channelId) { (success) in
                if success {
                    self.messageTxtBox.text = nil
                    self.messageTxtBox.placeholderText = "message"
                }
            }
        }
    }
    
    func onLoginGetMessages() {
        MessageService.instance.findAllChannels { (success) in
            if success {
                if MessageService.instance.channels.count > 0 {
                    MessageService.instance.selectedChannel = MessageService.instance.channels[0]
                    self.updateWithChannel()
                } else {
                    self.chatChannelLabel.text = "No channels Yet!"
                }
            }
        }
    }
    
    func getMessages() {
        guard let channelId = MessageService.instance.selectedChannel?.id else { return }
        MessageService.instance.findAllMessagesForChannel(channelID: channelId) { (success) in
            if success {
                
            }
        }
    }

}

