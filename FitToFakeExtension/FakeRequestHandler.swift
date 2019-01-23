//
//  FakeRequestHandler.swift
//  FitToFakeExtension
//
//  Created by Henry Lowengard on 8/18/18.
//  Copyright © 2018 Jhhl.net. All rights reserved.
//

import Foundation
import Intents

class FakeRequestHandler:
NSObject, INSendMessageIntentHandling,INSearchForMessagesIntentHandling {
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
//        print("oog!")
        let response = INSendMessageIntentResponse(
            code: .failureMessageServiceNotAvailable,
            userActivity: .none)
        completion(response)
    }
    
    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
    
    }
    
}
func handle(requestFake intent: INSendMessageIntent,
            completion: @escaping (INSendMessageIntentResponse) -> Void) {
//    print("hineini")
    
    let response = INSendMessageIntentResponse(
        code: .failureMessageServiceNotAvailable,
        userActivity: .none)
    completion(response)
}
