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
    
    let apiKey = "097831df4aa3483b8a1adcfb2b269ef9"
    
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
        }
        // convert to dictionaries and arrays
        
         do
         {
            json = try JSONSerialization.jsonObject(with: rawJSONData!) as? [String: Any]
         }
         catch
         {
            print(error)
            return nil
        }
        return json
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
