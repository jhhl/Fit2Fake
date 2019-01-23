//
//  IntentHandler.swift
//  FitToFakeExtension
//
//  Created by Henry Lowengard on 8/18/18.
//  Copyright © 2018 Jhhl.net. All rights reserved.
//

import Intents

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any? {
        if intent is INRequestRideIntent {
            return FakeRequestHandler()
        }
        return .none
    }
}

