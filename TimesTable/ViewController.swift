//
//  ViewController.swift
//  TimesTable
//
//  Created by Henry Lowengard on 9/26/17.
//  Copyright © 2017 Jhhl.net. All rights reserved.
//

import UIKit

class SectionCell:UICollectionViewCell
{
    @IBOutlet var lb_text:UILabel?
}

class InfoCell : UITableViewCell
{
 
}
class ViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextViewDelegate
{
    
    @IBOutlet var cv_sections:UICollectionView!
    @IBOutlet var tv_bylines:UITableView!
    @IBOutlet var lb_title:UILabel!
    @IBOutlet var txv_fakeNews:UITextView!
    @IBOutlet var sl_gensize:UISlider!

    public var dataSourceSections:[String]?
    public var dataSource:[String]?
    public var currentSection:String?
    
    var nytManager:NYTManager
    
    let evenColor = UIColor(red:0.99,green:0.96,blue:0.84,alpha:1.0)
    let oddColor = UIColor(red:0.90,green:0.96,blue:0.98,alpha:1.0)

    // MARK: - initializing and other setup

    // might need this
    required init?(coder aDecoder: NSCoder) {
        self.nytManager = NYTManager()
        super.init(coder:aDecoder)
    }
    
    /// set up things you can't set up in Interface Builder
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dataSourceSections = self.nytManager.sections
        self.dataSource = ["Pick a section, will ya?"] // will be filled by section query
        self.txv_fakeNews.text = "All the News That's Fit To Fake"
        self.setupCollectionView()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - collection view  delegate and datasource
    
    /// This is moved in with the collection stuff
    func setupCollectionView()
    {
        // fix up the collection view.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.itemSize = CGSize(width: 120.0, height: 20.0)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        cv_sections.collectionViewLayout = layout
    }
    
    // collection view datasource/delgate stuff
    var numberOfSections: Int {
        return 1
    }
    
    /// only one section here...
    ///
    /// - Parameters:
    ///   - collectionView:
    ///   - section:
    /// - Returns:
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(section == 0 )
        {
            return dataSourceSections!.count
        }
        return 0
    }
    
    /// fill that collection view with section keys
    ///
    /// - Parameters:
    ///   - collectionView:
    ///   - indexPath:
    /// - Returns: A cell
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell:SectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SectionCell",
                                                                  for: indexPath) as! SectionCell
        cell.lb_text!.text=dataSourceSections![indexPath.row]
        return cell
    }
    
    /// Collection View just has the possible sections of the paper to read. That then fills the info for the table.
    ///
    /// - Parameters:
    ///   - collectionView:
    ///   - indexPath:
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let cell:SectionCell = collectionView.cellForItem(at: indexPath) as! SectionCell
        currentSection =  cell.lb_text!.text!
        lb_title.text = currentSection
        // now we can perform the query that fills the table...
        if((nytManager.getJSON(section: currentSection!)) != nil)
        {
            dataSource = nytManager.recordsFor(key: "abstract")
            tv_bylines.reloadData()
        }
    }
    
    // MARK: - table view  delegate and datasource

 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
{
    let cellContent: String? = dataSource![indexPath.row]
    if(cellContent == nil)
    {
        return 40.0; // well, it's a cell, even if it's empty
    }
 
    return 80.0;
     }
    /// the TableView has results from the section query
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - section:
    /// - Returns: count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource!.count
    }
    
    /// Get that cell - in this case a bunch of bylines
    ///
    /// - Parameters:
    ///   - tableView:
    ///   - indexPath:
    /// - Returns: nicely configured cell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell",for: indexPath)
        cell.textLabel?.text = dataSource![row]
        cell.textLabel?.numberOfLines=0 // wrap all the time
        cell.backgroundColor = indexPath.row % 2 == 0 ? evenColor : oddColor;
        
        var superbounds = tableView.bounds
        superbounds.size.height = 10000.0
        cell.textLabel?.textRect(forBounds: superbounds, limitedToNumberOfLines: 50)
        return cell
    }
    // MARK: - disable typing into the text view
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    // MARK: - actions
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath  )
    {
        let row = indexPath.row
        let sentence = dataSource![row]
        // feed it to the generator.
        let nlpMan = NLPManager()
        let shared = SharedGrammar.sharedInstance;
        shared.enrollSentence( nlpMan.tokenify(sentence))
        generateFake()
    }
    func generateFake()
    {
        let shared = SharedGrammar.sharedInstance;
        let amount:UInt =   UInt(1000*sl_gensize.value) + 20
        let generated = shared.generate(amount)
        self.txv_fakeNews.text = generated
    }
    @IBAction func act_fakeIt()
    {
      generateFake()
    }
    @IBAction func act_forgetIt()
    {
        SharedGrammar.sharedInstance.forget()
    }
}

