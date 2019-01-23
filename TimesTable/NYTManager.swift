//
//  NYTManager.swift
//  TimesTable
//
//  Created by Henry Lowengard on 9/26/17.
//  Copyright © 2017 Jhhl.net. All rights reserved.
//

import UIKit

class NYTManager: NSObject {
 
    var rawJSONData:Data?
    var json: [String: Any]?
    
    // TODO: ideally, this api key would come out of a keystore, and be set  manually if unset
//    let apiKey = "097831df4aa3483b8a1adcfb2b269ef9"
    let apiKey = "iPqYn6jBHAARoKYPLvAVEZSZx1mAlq1G"
    // 9c941bae-4915-41b9-ace8-bab9084f8f7d
    // iPqYn6jBHAARoKYPLvAVEZSZx1mAlq1G
    // secret xAmRLAsEDGaIQYAl
    
    let sections:Array = [
     "home", "arts", "automobiles", "books", "business", "fashion",
     "food", "health", "insider", "magazine", "movies", "national",
     "nyregion", "obituaries", "opinion", "politics", "realestate",
     "science", "sports", "sundayreview", "technology", "theater",
     "tmagazine", "travel", "upshot", "world"
    ]
    
    
    /// Swift 4: throwing out even more syntax as time progresses
    ///
    /// - Parameter section: NYT section
    func getJSON(section:String) -> [String:Any]?
    {
        let nytURL:String = "https://api.nytimes.com/svc/topstories/v2/\(section).json?api-key=\(apiKey)"
        do
        {
            rawJSONData = try Data(contentsOf: URL(string: nytURL)!)
        }
        catch
        {
            print(error)
            json = fillWithTweets(reason: error.localizedDescription);
            return json
        }
        // convert to dictionaries and arrays
        
         do
         {
            json = try JSONSerialization.jsonObject(with: rawJSONData!) as? [String: Any]
            /*
             Optional<Dictionary<String, Any>>
             ▿ some : 1 element
             ▿ 0 : 2 elements
             - key : "fault"
             ▿ value : 2 elements
             ▿ 0 : 2 elements
             - key : detail
             ▿ value : 1 element
             ▿ 0 : 2 elements
             - key : errorcode
             - value : oauth.v2.InvalidApiKey
             ▿ 1 : 2 elements
             - key : faultstring
             - value : Invalid ApiKey
             
*/
            if (json?["fault"] != nil)
            {
                let reason  = "Bad API KEY";
                json = fillWithTweets(reason:reason);
            }
         }
         catch
         {
            print(error)
            return nil
        }
      
        return json
    }
    
    func fillWithTweets(reason: String) -> [String: Any]
    {
        json =   ["results":
            [
                ["abstract":"Sorry, couldn't get a connection to the NY Times API." ],
                ["abstract":"\(reason)" ],
                ["abstract":"Meanwhile, here are some samples:" ],
                ["abstract":"Facebook was always anti-Trump.The Networks were always anti-Trump hence,Fake News, @nytimes(apologized) & @WaPo were anti-Trump. Collusion?" ],
                ["abstract":"@CNN is #FakeNews. Just reported COS (John Kelly) was opposed to my stance on NFL players disrespecting FLAG, ANTHEM, COUNTRY. Total lie!" ],
                ["abstract":"The greatest influence over our election was the Fake News Media \"screaming\" for Crooked Hillary Clinton. Next, she was a bad candidate!" ],
                ["abstract":"Fascinating to watch people writing books and major articles about me and yet they know nothing about me & have zero access. #FAKE NEWS!" ],
                ["abstract": "General John Kelly is doing a fantastic job as Chief of Staff. There is tremendous spirit and talent in the W.H. Don't believe the Fake News"],
                ["abstract": "The Fake News is now complaining about my different types of back to back speeches. Well, there was Afghanistan (somber), the big Rally....."],
                ["abstract": "Last night in Phoenix I read the things from my statements on Charlottesville that the Fake News Media didn't cover fairly. People got it!"],
                ["abstract": " Jerry Falwell of Liberty University was fantastic on @foxandfriends. The Fake News should listen to what he had to say. Thanks Jerry!"],
                ["abstract": "Heading back to Washington after working hard and watching some of the worst and most dishonest Fake News reporting I have ever seen!"],
                ["abstract": "Steve Bannon will be a tough and smart new voice at @BreitbartNews...maybe even better than ever before. Fake News needs the competition!"],
                ["abstract":"The public is learning (even more so) how dishonest the Fake News is. They totally misrepresent what I say about hate, bigotry etc. Shame!"],
                ["abstract":"Made additional remarks on Charlottesville and realize once again that the #Fake News Media will never be satisfied...truly bad people!"],
                ["abstract":"After 200 days, rarely has any Administration achieved what we have achieved..not even close! Don't believe the Fake News Suppression Polls!"],
                ["abstract":"The Fake News Media will not talk about the importance of the United Nations Security Council's 15-0 vote in favor of sanctions on N. Korea!"],
                ["abstract":"Hard to believe that with 24/7 #Fake News on CNN, ABC, NBC, CBS, NYTIMES & WAPO, the Trump base is getting stronger!"],
            ]
        ]
        return json!;
    }
    
    public func recordsFor(key:String) -> Array<String>?
    {
        guard let results:[[String:Any]] = json!["results"] as? [[String:Any]]
            else
        {
            return nil
        }
        var records=[String]()
        
        for (_record) in results
        {
            let something:[String:Any?] = _record
            records.append((something[key] as! String?)!)
         }
        return records
    }
}
