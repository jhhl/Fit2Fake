//
//  TimesTableTests.swift
//  TimesTableTests
//
//  Created by Henry Lowengard on 9/26/17.
//  Copyright © 2017 Jhhl.net. All rights reserved.
//

import XCTest
@testable import TimesTable

class TimesTableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNYTAPI() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let nytManager = NYTManager();
        let k:Any? = nytManager.getJSON(section:"obituaries")
        XCTAssert(k != nil,"no value there")
    }
    
    func testNLPSplit()
    {
        let nlpMan = NLPManager()
        var result:[String]?
        
        result = nlpMan.tokenify("This is a simple String.")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 7,"parsed wrong number, got:\(result!.count)")
        
        result = nlpMan.tokenify("Jessica \"had\" a tall, white, tooth.")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 12,"parsed wrong number, got:\(result!.count)")
        
        result = nlpMan.tokenify("Mr. Bob Dobolina, Jr.")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 5,"parsed wrong number, got:\(result!.count)")
        
        result = nlpMan.tokenify("the X. files")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 3,"parsed wrong number, got:\(result!.count)")
        
        result = nlpMan.tokenify("the A.U.M.I. files")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 3,"parsed wrong number, got:\(result!.count)")
     
        result = nlpMan.tokenify("he had 1,234.56 dollars, and no cents")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 8,"parsed wrong number, got:\(result!.count)")
        
        result = nlpMan.tokenify("it cost $45.23")
        XCTAssert(result != nil,"no result")
        XCTAssert(result!.count == 3,"parsed wrong number, got:\(result!.count)")
    }
    
    func testEnroll()
    {
        let nlpMan = NLPManager()
        let shared = SharedGrammar.sharedInstance;
        
        shared.enrollSentence( nlpMan.tokenify("A B C B D E A F"))
        shared.enrollSentence( nlpMan.tokenify("D G H E F C A B"))

        
       print(" the vocabulary is here")
        for vocab in shared.symbols
        {
            print("Symbol: \(String(describing: vocab.symbol)) uuid: \(String(describing: vocab.uuid))")
        }
        print(" the rings are here")
        for symRing in shared.rings
        {
            let sym = shared.symbolForUUID(symRing.uuid)
            print("Ring: \(String(describing: sym))")
            for link in symRing.ring
            {
                let linkName = shared.symbolForUUID(link.uuid)
                print(" - Link: \(String(describing: linkName))")
            }
        }
        // test that generator
        print(" Generating")

        let gen = shared.generate( 30)
        print("\(gen)")
        
     
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
