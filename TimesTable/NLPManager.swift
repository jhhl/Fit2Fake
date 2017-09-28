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
        let filteredSentence = filterDots(sentence)
        //        var lastWasSpace: Bool = false
        
        for character in filteredSentence {
            switch character
            {
            case " ","\t","\n":
                if(word.count>0)
                {
                    word = filterBack(word)
                    words.append(word)
                }
                word = ""
                //                lastWasSpace=true
            // these guys link back to the anchor
            case ".", "!","?" :
                do {
                    word = filterBack(word)
                    words.append(word) // here's the word I was building
                    word = ""
                    word.append(character)
                    words.append(word) // here's the terminator
                    words.append(" ") // here's the anchor
                    word = ""
                }
            case  ",",":" ,";","\"","'":
                do {
                    word = filterBack(word)
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
            word = filterBack(word)
            words.append(word)
        }
        // unfilter this list
        
        return words
    }
    
    // in theory, these can be out-of-synch, and do other gross substitutions
    static let filterDict:[String:String] = [
        "Mr.":"Mr@",
        "Mrs.":"Mrs@",
        "Ms.":"Ms@",
        "Inc.":"Inc@",
        "Jr.":"Jr@",
        "Sr.":"Sr@",
        "Gov.":"Gov@",
        "Sen.":"Sen@",
        "Rev.":"Rev@",
        "St.":"St@",
        "Rd.":"Rd@",
        "Ave.":"Ave@"
    ]
    static let filterBackDict:[String:String] = [
        "Mr@":"Mr.",
        "Mrs@":"Mrs.",
        "Ms@":"Ms.",
        "Inc@":"Inc.",
        "Jr@":"Jr.",
        "Sr@":"Sr.",
        "Gov@":"Gov.",
        "Sen@":"Sen.",
        "Rev@":"Rev.",
        "St@":"St.",
        "Rd@":"Rd.",
        "Ave@":"Ave."

    ]
    
    func filterDots(_ s:String) ->String
    {
        var t = s;
        for (inWord,outWord) in NLPManager.filterDict
        {
            t = t.replacingOccurrences(of: inWord, with: outWord)
        }
        return t
    }
    
    func filterBack(_ s:String) -> String
    {
        var t = s;
        for (inWord,outWord) in NLPManager.filterBackDict
        {
            t = t.replacingOccurrences(of: inWord, with: outWord)
        }
        return t
    }
}
