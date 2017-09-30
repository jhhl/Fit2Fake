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
        var word = ""
        var words:[String] = [String]()
        let filteredSentence = filterDots(sentence)
        // thsi is because NSRegexx throws, inconveniently
        do
        {
//            let reNiceNumber = try  NSRegularExpression(pattern: "^[+-$]*[01234567890,]*([.][01234567890])*$")
            let reNiceNumber = try  NSRegularExpression(pattern: "^[$]*[01234567890,.]*$")
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
                    
                    // becuse comma and period can both be in a number... check with an re first. before "."
                case  ",",":" ,";","\"","'":
                    do {
                        // , might be in a number
                        if character == ","
                        {
                            //if this looks like a number
                            if reNiceNumber.firstMatch(in: word, options: [], range:NSMakeRange(0,word.count)) != nil
                            {
                                word.append(character)
                                continue
                            }
                        }
                        word = filterBack(word)
                        words.append(word)
                        word = ""
                        word.append(character)
                    }
                case ".", "!","?" :
                    do {
                        if character == "."
                        {
                            // a little logic: if that last word was only one letter,
                            // it's probably an abbreviation, not a sentence end.
                            if word.count == 1
                            {
                                word.append(character)
                                continue
                            }
                            // this may be an abbreviation like "G.M."
                            if word.contains(".")
                            {
                                word.append(character)
                                continue
                            }
                            //if this looks like a number
                            if reNiceNumber.firstMatch(in: word, options: [], range:NSMakeRange(0,word.count)) != nil
                            {
                                word.append(character)
                                continue
                            }
                        }
                        word = filterBack(word)
                        words.append(word) // here's the word I was building
                        word = ""
                        word.append(character)
                        words.append(word) // here's the terminator
                        words.append(" ") // here's the anchor
                        word = ""
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
        }
        catch
        {
            print ("BAD PATTERN!")
        }
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
        "Ave.":"Ave@",
        "Jan.":"Jan@",
        "Feb.":"Feb@",
        "Mar.":"Mar@",
        "Apr.":"Apr@",
        "Jun.":"Jun@",
        "Jul.":"Jul@",
        "Aug.":"Aug@",
        "Sep.":"Sep@",
        "Sept.":"Sept@",
        "Oct.":"Oct@",
        "Nov.":"Nov@",
        "Dec.":"Dec@",
        "'t":"@t",
        "'nt":"@nt",
        "'ll":"@ll",
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
        "Ave@":"Ave.",
        "Jan@":"Jan.",
        "Feb@":"Feb.",
        "Mar@":"Mar.",
        "Apr@":"Apr.",
        "Jun@":"Jun.",
        "Jul@":"Jul.",
        "Aug@":"Aug.",
        "Sep@":"Sep.",
        "Sept@":"Sept.",
        "Oct@":"Oct.",
        "Nov@":"Nov.",
        "Dec@":"Dec.",
        "@t":"'t",
        "@nt":"'nt",
        "@ll":"'ll",
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
