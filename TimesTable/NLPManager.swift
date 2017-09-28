//
//  NLPManager.swift
//  TimesTable
//
//  Created by Henry Lowengard on 9/27/17.
//  Copyright © 2017 Jhhl.net. All rights reserved.
//

import UIKit

class NLPManager: NSObject {

    /// split up a string into tokens.
    ///
    /// - Parameter s: a sentence (or paragraph or whatever)
    /// - Returns: array of words
    public func tokenify(_ sentence: String) -> [String]
    {
        var words:[String] = [String]()
        var word = ""
//        var lastWasSpace: Bool = false
        
        for character in sentence {
            switch character
            {
            case " ","\t":
                if(word.count>0)
                {
                    words.append(word)
                }
                word = ""
//                lastWasSpace=true
                
            case ".",",",":","!","?",";","\"","'":
                do {
                words.append(word)
                word = ""
                word.append(character)
                }
            default:
                word.append(character)
            }
        }
        if(word.count>0)
        {
            words.append(word)
        }
     return words
    }
 
}
