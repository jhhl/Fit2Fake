//
//  CorpusManager.swift
//  TimesTable
//
//  Created by Henry Lowengard on 6/14/19.
//  Copyright © 2019 Jhhl.net. All rights reserved.
// this needs a caching feature for the external stuff.
// that would mean changing the app to work off of its cached info
// and checking timestamps for newer resources on the server
// and updating them locally.
// that way it could work offline better.
//

import UIKit

class CorpusManager: NSObject
{
    var sectionMap:Dictionary<String,String>!;
     var rawJSONData:Data?
  
    var json: [String]? // now just an array of strings
    
// map should be fetched from the server.
//    let sectionMap:Dictionary = [
//        "home":"nyth",
//        "arts":"nyta",
//        "automobiles":"nytc",
//        "books":"nytb",
//        "business":"nytbiz",
//        "fashion":"nytf",
//        "food":"nytfood",
//        "health":"nythe",
//        "insider":"nyti",
//        "magazine":"nytmag",
//        "movies":"nytmov",
//        "national":"nytn",
//        "nyregion":"nytreg",
//        "obituaries":"nytobit",
//        "opinion":"nytop",
//        "politics":"nytp",
//        "realestate":"nytre",
//        "science":"nytsc",
//        "sports":"nyts",
//        "sundayreview":"nytsr",
//        "technology":"nyttech",
//        "theater":"nytth",
//        "tmagazine":"nytt",
//        "travel":"nyttrav",
//        "upshot":"nytu",
//        "world":"nytw",
//        "tweets":"d",
//        "Info":"info",
//        "Privacy":"privacy",
//        "Fake News":"nafake",
//        "Climate":"naclimate",
//        "Shocked!":"nashock"
//    ]
    
    func getSectionMap()
    {
        // get sectionMap from the server
        let mapURL:String = "https://jhhl.net/iPhone/Fit2Fake/data.php?d=1"
        do
        {
            rawJSONData = try Data(contentsOf: URL(string: mapURL)!)
        }
        catch
        {
            NSLog("failed map data reading \(error.localizedDescription)");
            
        }
        do{
            self.sectionMap = try JSONSerialization.jsonObject(with: rawJSONData!) as? Dictionary<String,String> ?? ["Info":"info",
                                        "Privacy":"privacy",
                                        "Tweets":"d",
                                        "Declaration":"dofi",
                                        "Bill Of Rights":"bollor"]
        }
        catch
        {
            NSLog("failed map serialiation \(error.localizedDescription)");

        }
//        NSLog("sectionMap:\(String(describing: self.sectionMap))")
    }
    
    /// Swift 4: throwing out even more syntax as time progresses
    ///
    /// - Parameter section: NYT section
    func getJSON(section:String) -> [String]?
{
    let decoded=self.sectionMap?[section]
    let corpusURL:String = "https://jhhl.net/iPhone/Fit2Fake/data.php?c=\(decoded ?? "d")"
    do
    {
        rawJSONData = try Data(contentsOf: URL(string: corpusURL)!)
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
        // should be an array of Anys, really
    json = try JSONSerialization.jsonObject(with: rawJSONData!) as? [String]
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
    if (json == nil)
    {
        let reason  = "Bad API KEY";
        json = fillWithTweets(reason:reason);
        }
    }
    catch
    {
        // some serialization error
        print(error)
        return nil
    }
    
    return json
    }
    
/// This is now an array of strings, not tiny dictionaries.
///
/// - Parameter reason: error eson
/// - Returns: json array
private func fillWithTweets(reason: String) -> [String]
{
    json =
        [
            "Sorry, couldn't get a connection to the API.",
            "\(reason)" ,
            "Meanwhile, here are some samples:" ,
            "Facebook was always anti-Trump.The Networks were always anti-Trump hence,Fake News, @nytimes(apologized) & @WaPo were anti-Trump. Collusion?" ,
            "@CNN is #FakeNews. Just reported COS (John Kelly) was opposed to my stance on NFL players disrespecting FLAG, ANTHEM, COUNTRY. Total lie!" ,
            "The greatest influence over our election was the Fake News Media \"screaming\" for Crooked Hillary Clinton. Next, she was a bad candidate!" ,
            "Fascinating to watch people writing books and major articles about me and yet they know nothing about me & have zero access. #FAKE NEWS!" ,
             "General John Kelly is doing a fantastic job as Chief of Staff. There is tremendous spirit and talent in the W.H. Don't believe the Fake News",
             "The Fake News is now complaining about my different types of back to back speeches. Well, there was Afghanistan (somber), the big Rally.....",
             "Last night in Phoenix I read the things from my statements on Charlottesville that the Fake News Media didn't cover fairly. People got it!",
             " Jerry Falwell of Liberty University was fantastic on @foxandfriends. The Fake News should listen to what he had to say. Thanks Jerry!",
             "Heading back to Washington after working hard and watching some of the worst and most dishonest Fake News reporting I have ever seen!",
             "Steve Bannon will be a tough and smart new voice at @BreitbartNews...maybe even better than ever before. Fake News needs the competition!",
            "The public is learning (even more so) how dishonest the Fake News is. They totally misrepresent what I say about hate, bigotry etc. Shame!",
            "Made additional remarks on Charlottesville and realize once again that the #Fake News Media will never be satisfied...truly bad people!",
            "After 200 days, rarely has any Administration achieved what we have achieved..not even close! Don't believe the Fake News Suppression Polls!",
            "The Fake News Media will not talk about the importance of the United Nations Security Council's 15-0 vote in favor of sanctions on N. Korea!",
            "Hard to believe that with 24/7 #Fake News on CNN, ABC, NBC, CBS, NYTIMES & WAPO, the Trump base is getting stronger!"
    ]
    return json!;
    }
    
    public func recordsFor() -> Array<String>?
{
    guard let results:[String] = json
    else
    {
        return nil
    }
    var records=[String]()
    // kind of doesn't need to be unwrapped...
    for (var _record) in results
    {
        // see if this decodes
        if let isoData = _record.data(using: .isoLatin1),
            let altFixed = String(data: isoData, encoding: .utf8) {
            _record = altFixed
        }
        records.append(_record)
    }
    return records
    }
    
}
