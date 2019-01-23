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
// these symbols might get reinterpreted though.

class Vocabulary:NSObject
{
    var symbol: String = ""
    var uuid: UInt = 0
    
    var seenCount: UInt = 0
    // eventually, this will tell the leaves from higher structures.
    var level: UInt = 0
    
    init(symbol sym: String, uuid uuidx: UInt)
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
    public var uuid:UInt!
    public var ring:[SymbolRing]!
    
    override init() {
        uuid  = 0
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
    public var serialNumber:UInt
    
    private init() {
        
        symbols = []
        rings = []
        serialNumber = 100000
        // build the anchor
        let voc = Vocabulary(symbol: " ", uuid: serialNumber)
        serialNumber += 1
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
        let voc = Vocabulary(symbol: " ", uuid: serialNumber)
        serialNumber += 1

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
    // it wouldn't kill me to have this be a method of the singleton and not a class function
    
    public class func getVocabulary(_ newSymbol:String) -> Vocabulary!
    {
        var voc = lookupVocabulary(newSymbol)
        if(voc == nil)
        {
            // must allocate one!
            voc = Vocabulary(symbol: newSymbol, uuid: sharedInstance.serialNumber)
            sharedInstance.serialNumber += 1
            let shared  = SharedGrammar.sharedInstance;
            shared.symbols.append(voc!)
        }
        return voc!
    }
    
    public class func lookupRingUUID(_ uuid:UInt) ->SymbolRing?
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
    
    public class func getFreshSymRing(_ uuid:UInt) -> SymbolRing!
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
    
    public func symbolForUUID(_ uuid:UInt) -> String?
    {
        let voc = vocabForUUID(uuid)
        if voc != nil
        {
            return voc?.symbol
        }
        return nil
    }
    
    public func vocabForUUID(_ uuid:UInt) -> Vocabulary?
    {
        for(voc) in SharedGrammar.sharedInstance.symbols
        {
            if(voc.uuid == uuid)
            {
                return voc
            }
        }
        return nil
    }
    
    public func pickSmartRandSymRing(_ ring:[SymbolRing]) -> SymbolRing?
    {
        // if there isnt a ring.
        if ring.count == 0
        {
            return nil
        }
        // don't waste time ..
        if ring.count == 1
        {
            return ring[0]
        }
        // this could be precalculated when seen is incremented.
        var sum: Double  = 0.0
        let K = 10000.0
        for sr in ring
        {
            let v = vocabForUUID(sr.uuid)!
            sum += K/(Double(v.seenCount) + 1.0)
        }
        // we now have a range for the randomness!
        //       1;6   2;4 3;3  1;6      c     sum = 19 (/12)
        //    |......|....|...|......|  ;[12*]  1/(1+c)
        //                      ^
        //
        let  r00000 = sum*Double(arc4random())/Double(0xFFFFFFFF)
         var sofar: Double  = 0.0

        for sr in ring
        {
            let v = vocabForUUID(sr.uuid)!
            sofar += K/(Double(v.seenCount) + 1.0)
            if sofar > r00000
            {
               return sr
            }
        }
        // shouldn't get there
        return ring[ring.count-1]
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
//            let nextIx = Int(arc4random()) %  spot.ring.count
//
//            spot = spot.ring[nextIx]
            // debug just for fun ...
//            let addADash =  spot.ring.count == 1
            
            spot = pickSmartRandSymRing(spot.ring)!
            // don't stick those spaces in or count them .
            if spot != anchor
            {
                let spotSym = symbolForUUID(spot.uuid)!
                result = "\(result) \(spotSym)"
//                    if addADash
//                    {
//                        result = "\(result)_"
//                    }
                countdown = countdown-1
            }
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


