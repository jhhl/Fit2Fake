//
//  ViewController.swift
//  TimesTable
//
//  Created by Henry Lowengard on 9/26/17.
//  Copyright © 2017 Jhhl.net. All rights reserved.
//

import UIKit
import AVFoundation

class SectionCell:UICollectionViewCell
{
    @IBOutlet var lb_text:UILabel?
}

class InfoCell : UITableViewCell
{
    @IBOutlet var lb_text:UILabel?
}

class ViewController:
    UIViewController,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextViewDelegate,
    UIDocumentInteractionControllerDelegate,
    AVSpeechSynthesizerDelegate
{
    
    @IBOutlet var cv_sections:UICollectionView!
    @IBOutlet var tv_bylines:UITableView!
    @IBOutlet var txv_fakeNews:UITextView!
    @IBOutlet var sl_gensize:UISlider!
    @IBOutlet var bt_share:UIButton!
    @IBOutlet var bt_speak:UIButton!

    public var dataSourceSections:[String]?
    public var dataSource:[String]?
    public var currentSection:String
    public var generationSentenceSize:UInt
    var sharedFilePath:String
    
    let nytManager:NYTManager = NYTManager()
    let speaker = AVSpeechSynthesizer()
    var talkAllTheTime = false;

    let evenColor = UIColor(red:0.99,green:0.96,blue:0.84,alpha:1.0)
    let oddColor = UIColor(red:0.90,green:0.96,blue:0.98,alpha:1.0)
    let normalColor = UIColor(white:1.0, alpha:0.0)
    let selectedColor = UIColor(white:0.0, alpha:0.1)
    
    // MARK: - initializing and other setup

    // might need this
    required init?(coder aDecoder: NSCoder) {
        generationSentenceSize = 150
        currentSection = "Choose A Section"
        sharedFilePath=""
        
        super.init(coder:aDecoder)
    }
    
    /// set up things you can't set up in Interface Builder
    override func viewDidLoad()
    {
        super.viewDidLoad()
// we should have speaker by now.
        speaker.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
        dataSourceSections = self.nytManager.sections
        dataSource = ["Choose a Section, will ya?"] // will be filled by section query
        txv_fakeNews.text = "All the News That's Fit To Fake"
        setupCollectionView()
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
        if (cell.lb_text!.text?.isEqual(currentSection))!
        {
            cell.backgroundColor=selectedColor
        }
        else
        {
            cell.backgroundColor=normalColor
        }
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
        collectionView.reloadData() // re-renders the cell backgrounds
        // now we can perform the query that fills the table...
        DispatchQueue.global(qos: .userInitiated).async {
            if((self.nytManager.getJSON(section: self.currentSection)) != nil)
            {
                self.dataSource = self.nytManager.recordsFor(key: "abstract")
                DispatchQueue.main.async {self.tv_bylines.reloadData()}
            }
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
        let cell:InfoCell = tableView.dequeueReusableCell(withIdentifier: "InfoCell",for: indexPath) as! InfoCell
        cell.lb_text?.text = dataSource![row]
        cell.lb_text?.numberOfLines=0 // wrap all the time
        cell.backgroundColor = indexPath.row % 2 == 0 ? evenColor : oddColor;
        
        var superbounds = tableView.bounds
        superbounds.size.height = 10000.0
        cell.lb_text?.textRect(forBounds: superbounds, limitedToNumberOfLines: 50)
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
        let generated = shared.generate(self.generationSentenceSize)
        self.txv_fakeNews.text = generated
        if(talkAllTheTime)
        {
            speak_start()
        }
    }
    
    @IBAction func act_fakeIt()
    {
      generateFake()
    }
    
    @IBAction func act_SliderIsSliding()
    {
        self.generationSentenceSize = UInt(1000*sl_gensize.value) + 20
    }
    @IBAction func act_SliderIsDone()
    {
        generateFake()
    }
    @IBAction func act_forgetIt()
    {
        SharedGrammar.sharedInstance.forget()
    }

    @IBAction func act_speak(_ button: UIButton)
    {
        button.isSelected = !button.isSelected
        
        talkAllTheTime = button.isSelected
        if button.isSelected
        {
            speak_start()
        }
        else
        {
            speak_stop()
        }
    }
    func speak_start()
    {
        if speaker.isSpeaking
        {
             speaker.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        bt_speak.setTitle( "STOP", for: UIControlState.normal)
        let utterance = AVSpeechUtterance(string:txv_fakeNews.text)
        speaker.speak(utterance)
    }
    func speak_stop()
    {
        bt_speak.setTitle( "SPEAK", for: UIControlState.normal)
        speaker.stopSpeaking(at: AVSpeechBoundary.word)
    }
    
    // delegate methods for speaker
     func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
     {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
         speak_stop()
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance)
    {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance)
    {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance)
    {
         speak_stop()
    }
    
    // MARK: - Document sharing: doesn't work too well for some reason.
    
    @IBAction func act_share(_ button: UIButton)
    {
        //        let rect = button.convert(button.frame, to: self.view)
        var rect = button.frame
        rect.origin.y = rect.origin.y + (button.superview?.frame.origin.y)!
        //        var rect = button.frame
        //        rect.origin.y=40.0
        share(rect)
    }
    
    public func share(_ rect:CGRect)
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let now = NSDate()
        sharedFilePath = documentsPath + "/fit2fake \(now).txt"
        
        // save out that text
        let fakeText:String = txv_fakeNews.text;
        do {
            try fakeText.write(toFile: sharedFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch
        {
        }
        
        let url = URL(fileURLWithPath: sharedFilePath)
        
        let docController = UIDocumentInteractionController(url: url)
        docController.delegate = self;
        docController.presentOptionsMenu(from: rect, in: self.view, animated: true)
    }
    
 
    func removeSharedFile()
    {
        do {
            try FileManager.default.removeItem(atPath: sharedFilePath)
        }
        catch
        {
        }
    }
 
    // Options menu presented/dismissed on document.  Use to set up any HI underneath.
      func documentInteractionControllerWillPresentOptionsMenu(_ controller: UIDocumentInteractionController)
    {
    }
    
      func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController)
     {
        removeSharedFile()
    }
    
    // Open in menu presented/dismissed on document.  Use to set up any HI underneath.
      func documentInteractionControllerWillPresentOpenInMenu(_ controller: UIDocumentInteractionController)
    {
    }
      func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController)
    {
        removeSharedFile()
    }
    
    // Synchronous.  May be called when inside preview.  Usually followed by app termination.  Can use willBegin... to set annotation.
      func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) // bundle ID
    {
        
    }
      func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?)
    {
        
    }
    
}

