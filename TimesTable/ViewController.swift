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
    @IBOutlet var iv_view:UIImageView?
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
    @IBOutlet var tv_corpus:UITableView!
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
    
//    let nytManager:NYTManager = NYTManager()
    let corpusManager:CorpusManager = CorpusManager()
    let speaker = AVSpeechSynthesizer()
    var speakTheNews = false
    var docController: UIDocumentInteractionController?
    var activityController: UIActivityViewController?
    var saveAsImage:Bool = true
    var saveAsJPEGImage:Bool=false

    let evenColor = UIColor(red:0.99,green:0.96,blue:0.84,alpha:1.0)
    let oddColor = UIColor(red:0.99,green:0.98,blue:0.99,alpha:1.0)
    let pageColor = UIColor(red:0.994,green:0.962,blue:0.846,alpha:1.0)

//    let evenColor = UIColor(patternImage: UIImage(named: "newsprint0")!)
//    let oddColor = UIColor(patternImage: UIImage(named: "newsprint1")!)
    let normalColor = UIColor(white:1.0, alpha:0.0)
    let selectedColor = UIColor(white:0.0, alpha:0.1)
    
    var continuousSpeech:Bool = false;
    var currentInfo:[Int] = [];
    
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
        if saveAsJPEGImage
        {
            bt_sharePic.setTitle("SHARE: jpg", for: .normal)
        }
        else
        {
            bt_sharePic.setTitle("SHARE: png", for: .normal)
        }
        bt_sharePic.titleLabel?.numberOfLines=2
        self.corpusManager.getSectionMap()
        // Do any additional setup after loading the view, typically from a nib.
//        dataSourceSections = self.nytManager.sections
        dataSourceSections = Array(self.corpusManager.sectionMap.keys).sorted()
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
//        cell.lb_text!.numberOfLines=2
//        cell.lb_text!.adjustsFontSizeToFitWidth=true
//        cell.lb_text!.minimumScaleFactor=0.5
        // this means we have a new bunch of rows, so clear the "current one"
        self.currentInfo.removeAll()

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
//            if((self.nytManager.getJSON(section: self.currentSection)) != nil)
            if((self.corpusManager.getJSON(section: self.currentSection)) != nil)
            {
//                self.dataSource = self.nytManager.recordsFor(key: "abstract")
                self.dataSource = self.corpusManager.recordsFor()
                DispatchQueue.main.async {self.tv_corpus.reloadData()}
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
//        cell.backgroundColor = indexPath.row % 2 == 0 ? evenColor : oddColor;
        let eoName:String = self.currentInfo.contains(indexPath.row) ? "newsprint0" :
            indexPath.row % 2 == 0 ? "newsprint2" : "newsprint3";
        
        cell.iv_view!.image = UIImage(named: eoName);
        
        var superbounds = tableView.bounds
        superbounds.size.height = 10000.0
        cell.lb_text?.textRect(forBounds: superbounds, limitedToNumberOfLines: 50)
        return cell
    }
    // MARK: - disable typing into the text view
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //  generate fakeness though!
        generateFake()
        return false
    }
    
    // MARK: - actions
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath  )
    {
        let cell:InfoCell = tableView.cellForRow(at: indexPath) as! InfoCell
        // show that it's selected ... but when it refreshes, it won't know.
        let row = indexPath.row
        self.currentInfo.append(row);
        cell.iv_view!.image = UIImage(named:"newsprint0")

        let sentence = dataSource![row]
        // feed it to the generator.
        let nlpMan = NLPManager()
        let shared = SharedGrammar.sharedInstance;
        shared.enrollSentence( nlpMan.tokenify(sentence))
        generateFake()
    }
    
    // marked objc so it can be called by selector
    //
    @objc func generateFake()
    {
        let shared = SharedGrammar.sharedInstance;
        let generated = shared.generate(self.generationSentenceSize)
        let nlpMan = NLPManager()
        //TODO: animate this?
        UIView.animate(withDuration: 0.25, animations: {
            self.txv_fakeNews.alpha = 0.0;
        }) { (Bool) in
             self.txv_fakeNews.text = nlpMan.smoosh(generated)
            UIView.animate(withDuration: 0.25, animations: {
                self.txv_fakeNews.alpha = 1.0;
            }) { (Bool) in
                if(self.speakTheNews)
                {
                    self.speak_start()
                }
            }
        }
        //
//        self.txv_fakeNews.text = nlpMan.smoosh(generated)
//        if(speakTheNews)
//        {
//            speak_start()
//        }
    }
    
    // no longer need a separate button.
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
        dataSource = ["Choose a Section, will ya?"] // wipe out and will be filled by section query
        self.currentInfo.removeAll()
        self.tv_corpus.reloadData()
        self.tv_corpus.scrollToNearestSelectedRow(at: .top, animated: true)
        speak_stop()
     }
    
//MARK:  -Speaking
    @IBAction func act_speak(_ button: UIButton)
    {
        button.isSelected = !button.isSelected
        
        speakTheNews = button.isSelected
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
        bt_speak.setTitle( "SILENCE", for: UIControlState.normal)
        let utterance = AVSpeechUtterance(string:txv_fakeNews.text)
        speaker.speak(utterance)
    }
    
    func speak_stop()
    {
        bt_speak.setTitle(continuousSpeech ? "RADIO" : "SPEAK", for: UIControlState.normal)
        speaker.stopSpeaking(at: AVSpeechBoundary.word)
    }
    
    /// long press pass though will toggle continous "radio" mode talking.
    ///
    /// - Parameter gestureRecognizer:
    @IBAction func act_LongPressGestured(_ gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == .began
        {
            continuousSpeech = !continuousSpeech
            if continuousSpeech
            {
                speak_start()
            }
            else
            {
                speak_stop()
            }
        }
    }
    
//MARK: - delegate methods for speaker
     func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance)
     {
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        if continuousSpeech
        {
//            let _ = Timer(timeInterval: 0.4, repeats: false) { _ in self.generateFake()}
            self.perform(#selector(generateFake), with: nil, afterDelay: 0.5)
        }
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
        let fakeText:String = "All The News That's Fit To Fake on \(stamp)\n \(realText)\n";

        if(saveAsImage)
        {
            let textSize = CGSize(width:600.0,height:400.0)
            let theImage = self.imageFromText(fakeText, size: textSize)
            if(saveAsJPEGImage)
            {
                sharedFilePath = documentsPath + "/fit2fake\(stampNoSpace).jpg"
                let url = URL(fileURLWithPath: sharedFilePath)
                
                if writeJPEGImageToFile(image: theImage!,file: sharedFilePath)
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
                sharedFilePath = documentsPath + "/fit2fake\(stampNoSpace).png"
                let url = URL(fileURLWithPath: sharedFilePath)
                
                if writePNGImageToFile(image: theImage!,file: sharedFilePath)
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

        }
        else
        {
            
            activityController = UIActivityViewController(activityItems: [fakeText], applicationActivities: nil);
            activityController?.popoverPresentationController?.sourceView = self.view
            // send that text to an activity
            self.present(activityController!, animated: true, completion: nil)
 
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
    
    private func writeJPEGImageToFile(image:UIImage, file:String) -> Bool
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
    
    private func writePNGImageToFile(image:UIImage, file:String) -> Bool
    {
        let imageURL:URL = URL(fileURLWithPath: file)
        let photoData:Data = UIImagePNGRepresentation(image)!
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

