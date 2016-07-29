//
//  ViewController.swift
//  ParseHTML
//
//  Created by Le Tan Thang on 5/11/16.
//  Copyright © 2016 Le Tan Thang. All rights reserved.
// Parse data from : http://www.masokaraoke.net
//

import Cocoa
import Kanna

class ViewController: NSViewController {

    @IBOutlet weak var volText: NSTextField!
    
    @IBOutlet weak var pageNumText: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        

        
        
    }
    
    @IBAction func parseAndExport(sender: AnyObject) {
        
        var dict = [[String: AnyObject]]()
        guard let vol = Int(self.volText.stringValue) else {
            return
        }
        guard let totalPage = Int(self.pageNumText.stringValue) else {
            return
        }
        
        let fileName = "vol\(vol).json"
        
        
        for var i = 0; i < totalPage; i++ {
            let urlString = "http://www.masokaraoke.net/vol/ma-so-karaoke-vol-\(vol)/?page=\(i)"
            parseHTML(urlString, result: &dict)
            usleep(300)
        }
        
        
        exportToFile(dict,fileName: fileName)
        
        
        print("file: \(fileName)")
        print("vol:\(vol)")
        print("pages: \(totalPage)")
        print("songs: \(dict.count)")
        
    }
    
    func exportToFile(dict: [[String: AnyObject]], fileName: String) {
        do {
            
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted) // or no options ... dataWithJSONObject(dict, options: [])
            
            if let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first {
                
                let fileURL = NSURL(fileURLWithPath: documentPath).URLByAppendingPathComponent(fileName)
                //print(fileURL)
                
                jsonData.writeToURL(fileURL, atomically: true)
                
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }
    func parseHTML(urlString: String, inout result: [[String: AnyObject]]) {
        
        
        
        guard let url = NSURL(string: urlString) else {
            print("Error: \(urlString) is not a valid url")
            return
        }
        
        
        
        let html = try! String(contentsOfURL: url)
        
        
        if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
            
            //print(urlString)
            
            for div in doc.css("#resultSong .song") {
                if let songID = div.css(".songID").first {
                    if let songName = div.css(".songName").first {
                        
                        let songIDString = songID.text!
                        
                        //print(songIDString)
                        
                        
                        let index =  songIDString.startIndex.advancedBy(5)
                        let songCode = songIDString.substringToIndex(index)
                        let songVol = songIDString.substringFromIndex(index.advancedBy(1))
                        
                        var temp = [String:AnyObject]()
                       
                        
                        let songAuthor: String = div.css(".author").first!.text!
                        temp["songAuthor"] = songAuthor
                        temp["songInfo"] = songAuthor
                        temp["songInfo_"] = stripDiacritics(songAuthor)
                        
                        
                        var songLyric: String = div.css(".SongLyric").first!.text!
                        if songLyric.characters.count > 3 {
                            let end = songLyric.endIndex.advancedBy(-3)
                            songLyric = songLyric.substringToIndex(end)
                            
                        } else {
                            songLyric = ""
                        }
                        
                        temp["songLyric"] = songLyric
                        temp["songLyric_"] = stripDiacritics(songLyric)
                        
                        
                        temp["songVol"] = songVol
                        temp["songCode"] = songCode
                        temp["songName_"] = stripDiacritics(songName.text!)
                        temp["songName"] = songName.text!
                        result.append(temp)
                        
                        
                        
                        //print("Ma so: " + songCode + " Vol: " + songVol + " Ten: " + songName.text!)
                    }
                    
                    
                }
            }
            
        }

    }

    func stripDiacritics(text: String) -> String {
        let input = text as NSString
        let convertedString = NSMutableString(string: input) as CFMutableStringRef
        
        CFStringTransform(convertedString, nil, kCFStringTransformStripCombiningMarks, false) // or use kCFStringTransformStripDiacritics
        
        var result = (convertedString as String)
        
        
        // replace "đ"
        result = result.stringByReplacingOccurrencesOfString("đ", withString: "d")
        
        return result
    }

}

