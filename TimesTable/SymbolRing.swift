//
//  SymbolRing.swift
//  TimesTable
//
//  Created by Henry Lowengard on 9/27/17.
//  Copyright © 2017 Jhhl.net. All rights reserved.
//

import UIKit


/// This is the place where a piece of dictionary is kept.
// linking is through the uuids, though.

class Vocabulary:NSObject
{
    var symbol: String = ""
    var uuid: TimeInterval = 0.0
    var seenCount: UInt = 0
    
    init(symbol sym: String, uuid uuidx: TimeInterval)
    {
        self.uuid=uuidx
        self.symbol=sym
        super.init()
    }
    
}


/// this may grow some more data to match when looking for the next "ring",
// for instance a sentence ID would mean it was once used in the same sentence as somenting.

class SymbolRing: NSObject
{
    public var uuid:TimeInterval!
    public var ring:[SymbolRing]!
    
    override init() {
        uuid  = Date.timeIntervalSinceReferenceDate
        ring=[SymbolRing]()
        super.init()
    }
}

class SharedGrammar {
    
    static let sharedInstance = SharedGrammar()
    public var symbols:[Vocabulary]
    public var rings:[SymbolRing]
    public var anchor:SymbolRing
    public var cursor:SymbolRing
    
    private init() {
        
        symbols = []
        rings = []
        
        // build the anchor
        let voc = Vocabulary(symbol: " ", uuid: Date.timeIntervalSinceReferenceDate)
        symbols.append(voc)
        
        // this assigns the anchor to this voc's uuid
        anchor = SymbolRing()
        anchor.uuid = voc.uuid
        rings.append(anchor)
        
        cursor = anchor
    }
    
    /// this is also used by the forgetter, so it can reinitialize.
    // can't be called by init though.
    public func buildAnchor()
    {
        // build the anchor
        let voc = Vocabulary(symbol: " ", uuid: Date.timeIntervalSinceReferenceDate)
        symbols.append(voc)
        
        // this assigns the anchor to this voc's uuid
        anchor = SymbolRing()
        anchor.uuid = voc.uuid
        rings.append(anchor)
        
        cursor = anchor
    }
    
    public func linkToRing(_ voc: Vocabulary)
    {
        // make a new link:
        let sr = SharedGrammar.getFreshSymRing(voc.uuid)
        // update the count
        let k = voc.seenCount + 1
        voc.seenCount = k
        // link it
        cursor.ring.append(sr!)
        // advance the cursor
        cursor = sr!
    }
    
    /// sometimes, we want to clean these counts.
    /// they aren't that important anyway
    public func cleanCounts()
    {
        for voc in symbols
        {
            voc.seenCount=0;
        }
    }
    
    /// it's a good idea to start each sentence off of the anchor link.
    public func reanchor()
    {
        self.cursor = self.anchor
    }
    
    public func enrollSentence(_ words: [String])
    {
        self.reanchor()
        for symbol in words
        {
            let voc = SharedGrammar.getVocabulary(symbol)!
            SharedGrammar.sharedInstance.linkToRing(voc)
        }
        // link back to the anchor.
        let voc = SharedGrammar.getVocabulary(" ")!
        SharedGrammar.sharedInstance.linkToRing(voc)
    }
    
    
    /// find it in the vocab. yeah, nice to be indexed.
    ///
    /// - Parameter newSymbol:
    /// - Returns:
    public class func lookupVocabulary(_ newSymbol:String) ->Vocabulary?
    {
        let shared = SharedGrammar.sharedInstance;
        for(voc) in shared.symbols
        {
            if(voc.symbol.isEqual(newSymbol))
            {
                return voc
            }
        }
        return nil
    }
    
    /// find or allocate a new voc.
    ///
    /// - Parameter newSymbol:
    /// - Returns: a nice Vocabulary, new or old.
    
    public class func getVocabulary(_ newSymbol:String) -> Vocabulary!
    {
        var voc = lookupVocabulary(newSymbol)
        if(voc == nil)
        {
            // must allocate one!
            voc = Vocabulary(symbol: newSymbol, uuid: Date.timeIntervalSinceReferenceDate)
            let shared  = SharedGrammar.sharedInstance;
            shared.symbols.append(voc!)
        }
        return voc!
    }
    
    public class func lookupRingUUID(_ uuid:TimeInterval) ->SymbolRing?
    {
        let shared = SharedGrammar.sharedInstance;
        for(sr) in shared.rings
        {
            if(sr.uuid == uuid)
            {
                return sr
            }
        }
        return nil
    }
    
    public class func getFreshSymRing(_ uuid:TimeInterval) -> SymbolRing!
    {
        var symR = lookupRingUUID(uuid)
        if(symR == nil)
        {
            // this assigns it to this uuid
            symR = SymbolRing()
            symR!.uuid = uuid
            let shared  = SharedGrammar.sharedInstance;
            shared.rings.append(symR!)
        }
        return symR!
    }
    
    public func symbolForUUID(_ uuid:TimeInterval) -> String?
    {
        for(voc) in SharedGrammar.sharedInstance.symbols
        {
            if(voc.uuid == uuid)
            {
                return voc.symbol
            }
        }
        
        return nil
    }
    
    public func generate(_ howMany:UInt) -> String
    {
        if anchor.ring.count < 1
        {
            return "Not enough words yet"
        }
        
        // always start from anchor
        var spot = anchor
        var result = ""
        var countdown = howMany
        while countdown > 0
        {
            // pick the next one.
            // this will get smarter and use the counter (inversely) to weigh the choices.
            //   a larger weight means a smaller chance.
            // also, it will inc  the counter when chosen.
            let nextIx = Int(arc4random()) %  spot.ring.count
            
            spot = spot.ring[nextIx]
            let spotSym = symbolForUUID(spot.uuid)!
            result = "\(result) \(spotSym)"
            countdown = countdown-1
            // stop at the end of a sentence unless we didn't really gen anything
            if spot == anchor && countdown < howMany - 2
            {
                countdown=0
            }
        }
        return result
    }
    
    public func forget()
    {
        self.symbols.removeAll()
        self.rings.removeAll()
        self.buildAnchor()
    }
}


