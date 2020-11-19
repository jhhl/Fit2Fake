//
//  FakeRequestHandler.swift
//  FitToFakeExtension
//
//  Created by Henry Lowengard on 8/18/18.
//  Copyright © 2018 Jhhl.net. All rights reserved.
//

import Foundation
import Intents

class FakeRequestHandler:NSObject,
    INSendMessageIntentHandling,
INSearchForMessagesIntentHandling
{
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        //        print("oog!")
        // look at Intent for clues
        /*
         po intent
         {
             speakableGroupName = <null>;
             content = Hi;
             serviceName = <null>;
             recipients = (
             );
             conversationIdentifier = <null>;
             sender = <null>;
         }
         */
        let response = INSendMessageIntentResponse(
            code: .success, //.failureMessageServiceNotAvailable,
            userActivity: .none)
        completion(response)
    }
    
    // - (void)handleSetMessageAttribute:(INSetMessageAttributeIntent *)intent
    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void)
    {
        // look at Intent for clues
        let response = INSetMessageAttributeIntentResponse(
        code: .success, //.failureMessageServiceNotAvailable,
        userActivity: .none)
        
        completion(response)
    }
    
    
    // Find messages from Nemo about movies on Fit 2 Fake
    func handle(intent: INSearchForMessagesIntent,
                completion: @escaping (INSearchForMessagesIntentResponse) -> Void)
    {
        for term in intent.searchTerms ?? []
        {
        print(term)
        }
        
        let fakeMeHandle = INPersonHandle(value: "Fit 2 Faker", type: .unknown)
        var fakeMePNCs = PersonNameComponents()
        fakeMePNCs.namePrefix = "St."
        fakeMePNCs.givenName="Fit"
        fakeMePNCs.middleName="To"
        fakeMePNCs.familyName="Fake"
        fakeMePNCs.nameSuffix=nil
        fakeMePNCs.nickname="Fitty"
        fakeMePNCs.phoneticRepresentation=nil
        
        let fakeMe = INPerson(personHandle: fakeMeHandle, nameComponents: fakeMePNCs, displayName: "Fit 2 Fake Staff", image: nil, contactIdentifier: "ContactId", customIdentifier: "CustID")
        let fakeResponse = makeFake(keys: intent.searchTerms ?? [])
        
        let responseMessage  = INMessage(
            identifier: "msg000",
            content: fakeResponse,
            dateSent: Date(),
            sender: fakeMe,
            recipients: nil)
        
        let inMessages = [responseMessage]
        
        let activity =  NSUserActivity(activityType: "net.jhhl.fit2fake.news")
        activity.title = "News"
        activity.isEligibleForHandoff=false
        activity.isEligibleForSearch=true
        activity.isEligibleForPublicIndexing=false
        
// I don't know if I need a becomeCurrent that might be siri's job
        
        let response = INSearchForMessagesIntentResponse(
            code: .success, //.failureMessageServiceNotAvailable,
            userActivity: activity)
        //??!!!
        response.messages = inMessages
        
        completion(response)
    }
}
func makeFake(keys: [String]) -> String
{
    // use the keys to find sections to fake ?
    
    let nlpMan = NLPManager()
    let shared = SharedGrammar.sharedInstance;  
    let generated = shared.generate(150)
    let cleanedUp = nlpMan.smoosh(generated)
    
    print(cleanedUp)
    
    return "hoo haha!"
}



func handle(requestFake intent: INSendMessageIntent,
            completion: @escaping (INSendMessageIntentResponse) -> Void) {
    //    print("hineini")
    
    let response = INSendMessageIntentResponse(
        code: .failureMessageServiceNotAvailable,
        userActivity: .none)
    completion(response)
}
