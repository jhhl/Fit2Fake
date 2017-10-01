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
    @IBOutlet var bt_shareTxt:UIButton!
    @IBOutlet var bt_sharePic:UIButton!
    @IBOutlet var bt_speak:UIButton!

    public var dataSourceSections:[String]?
    public var dataSource:[String]?
    public var currentSection:String
    public var generationSentenceSize:UInt
    var sharedFilePath:String
    
    let nytManager:NYTManager = NYTManager()
    let speaker = AVSpeechSynthesizer()
    var talkAllTheTime = false
    var docController: UIDocumentInteractionController?
    var saveAsImage:Bool = true
    
    let evenColor = UIColor(red:0.99,green:0.96,blue:0.84,alpha:1.0)
    let oddColor = UIColor(red:0.99,green:0.98,blue:0.99,alpha:1.0)
    let pageColor = UIColor(red:0.994,green:0.962,blue:0.846,alpha:1.0)
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
        bt_shareTxt.titleLabel?.numberOfLines=2
        bt_sharePic.titleLabel?.numberOfLines=2

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
        txv_fakeNews.text = "All the News That's Fit To Fake"
        speak_stop()
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
    // this now lets it speak all the time, and then stop doing that.
    
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
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance)
    {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance)
    {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance)
    {
    }
    
    // MARK: - Document sharing: doesn't work too well for some reason.
    
    @IBAction func act_shareText(_ button: UIButton)
    {
        //        let rect = button.convert(button.frame, to: self.view)
        var rect = button.frame
        rect.origin.y = rect.origin.y + (button.superview?.frame.origin.y)!
        saveAsImage=false;
        share(rect)
    }
    @IBAction func act_sharePic(_ button: UIButton)
    {
        //        let rect = button.convert(button.frame, to: self.view)
        var rect = button.frame
        rect.origin.y = rect.origin.y + (button.superview?.frame.origin.y)!
        saveAsImage=true
        share(rect)
    }
    public func share(_ rect:CGRect)
    {
        //
        let documentsPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        cleanoutOldFiles()
        
        let df = DateFormatter()
        df.dateFormat = "MMM dd,yyyy HH:mm:ss"
        let stamp = df.string(from: Date())
        df.dateFormat = "MMddyy-HHmmss"
        let stampNoSpace = df.string(from: Date())
        let realText = txv_fakeNews.text ?? ""
        let fakeText:String = "All The News That's Fit To Fake on \(stamp)\n \(realText)";

        if(saveAsImage)
        {
            sharedFilePath = documentsPath + "/fit2fake\(stampNoSpace).jpg"
            let url = URL(fileURLWithPath: sharedFilePath)

            let textSize = CGSize(width:600.0,height:400.0)
            let theImage = self.imageFromText(fakeText, size: textSize)
            if writeImageToFile(image: theImage!,file: sharedFilePath)
            {
                docController = UIDocumentInteractionController(url: url)
                docController!.delegate = self;
                docController!.presentOptionsMenu(from: rect, in: self.view, animated: true)
            }
            else
            {
                print("some problem writing image to file")
            }

        }
        else
        {
            // ths is so we can save them as separate documents in a file system.
            sharedFilePath = documentsPath + "/fit2fake\(stampNoSpace).txt"
            let url = URL(fileURLWithPath: sharedFilePath)
            
            // save out that text
            
            do {
                
                try fakeText.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                docController = UIDocumentInteractionController(url: url)
                docController!.delegate = self;
                docController!.presentOptionsMenu(from: rect, in: self.view, animated: true)
                //            docController!.presentOpenInMenu(from: rect, in: self.view, animated: true)
            }
            catch
            {
                print(error)
                return
            }
        }
    }
    
  func cleanoutOldFiles()
  {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let paths = FileManager.default.subpaths(atPath: documentsPath)
    for path:String in paths!
    {
        if path.contains("fit2fake")
        {
            do {
            try FileManager.default.removeItem(atPath: documentsPath+"/"+path)
            }
            catch
            {
                print(error)
            }
        }
    }
    
    
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
    
    // MARK: image Utils
    
    func writeTextAsImage(text:String, file filePath:String, size sizing:CGSize) ->URL?
    {
        let theImage =  self.imageFromText(text, size: sizing)
        
        let success =   self.writeImageToFile(image:theImage!, file:filePath)
        if(success)
        {
            return URL(fileURLWithPath: filePath)
        }
        return nil
    }
    
    private func imageFromText(_ text:String, size sizing:CGSize) -> UIImage!
    {
        
        //        let _textFont = UIFont.systemFont(ofSize: 16)
        let _textFont = UIFont.init(name: "Times New Roman", size: 16.0)
        let _textColor = UIColor.black
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        let attributes = [
            NSAttributedStringKey.font: _textFont!,
            NSAttributedStringKey.foregroundColor: _textColor,
            ]
        let superSize = CGSize(width:sizing.width,height:100000.0)
        let niceRect = text.boundingRect(with: superSize, options: [NSStringDrawingOptions.usesLineFragmentOrigin ], attributes: attributes, context: nil)
        let niceSize=CGSize(width: 8.0*floor((niceRect.size.width/8.0)+1.0), height: 20.0*floor((niceRect.size.height/20.0)+1.0))
        UIGraphicsBeginImageContextWithOptions(niceSize, false, scale)
        
        let atPoint=CGPoint(x:0.0, y:0.0)
        
        // Create a point within the space that is as big as the image
        let rect = CGRect(origin:atPoint, size:niceSize)
        // color the page nicely
        pageColor.setFill()
        //set the desired background color
        UIRectFill(CGRect(x:0.0,y:0.0,width:niceSize.width,height:niceSize.height))
        
        // Draw the text into an image
        text.draw(in: rect, withAttributes:  [
            NSAttributedStringKey.font: _textFont!,
            NSAttributedStringKey.foregroundColor: _textColor,
            ])

        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage
    }
    
    private func writeImageToFile(image:UIImage, file:String) -> Bool
    {
        let imageURL:URL = URL(fileURLWithPath: file)
        let photoData:Data = UIImageJPEGRepresentation(image, 1)!
        do
        {
            try photoData.write(to: imageURL)
            return true
        }
        catch
        {
            print("bad image write")
        }
        return false
    }
    
}

