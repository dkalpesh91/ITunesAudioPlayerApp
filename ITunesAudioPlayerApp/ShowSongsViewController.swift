//
//  ViewController.swift
//  ITunesAudioPlayerApp
//
//  Created by Kingfisher on 7/25/16.
//  Copyright © 2016 dahlia. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}


class ShowSongsViewController: UIViewController, SongsDetailsResponseDelegate,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var showSongsTableView: UITableView!
    
    var showSongsViewModelObject = ShowSongsViewModel()
    var songsDetails = [ShowSongsViewModel]()
    
    var imageCache = [String:UIImage]()
    var songUrl = [String]()
    
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCache["music"] = UIImage(named: "music.png")
        
        self.showSongsViewModelObject.delegate = self
        showSongsViewModelObject.getJSONFromRequest()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setSongsDetailsResponseDetails(response:[ShowSongsViewModel],httpResponsCode:Int) {
        if httpResponsCode != UrlConstant.HTTP_SUCCESS {
            
            let alert = UIAlertController(title: "Server Error", message: "Server is down or check your internet connection", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else {
            songsDetails = response
            showSongsTableView.reloadData()
            print("valid HTTP response = \(songsDetails)")
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songsDetails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let simpleTableIdentifier : String  = "songsCell"
        let cell = tableView .dequeueReusableCellWithIdentifier(simpleTableIdentifier, forIndexPath: indexPath) as! ShowSongsTableViewCell
        
        showSongsViewModelObject = songsDetails[indexPath.row]
        
        cell.trackNameLable.text = String(showSongsViewModelObject.trackName!)
        cell.artistNameLable.text = String(showSongsViewModelObject.artistName!)
        cell.timeLable.text = String(showSongsViewModelObject.time!)
        cell.releaseDateLable.text = String(showSongsViewModelObject.releaseDate!)
        cell.priceLable.text = "$"+" "+"\(String(showSongsViewModelObject.price!))"
        cell.imageView!.imageFromUrl(String(showSongsViewModelObject.price!))
        loadImageFromUrl(String(showSongsViewModelObject.imageUrl!), view: cell.songImageView)
        songUrl.append(String(showSongsViewModelObject.songPlayUrl!))
        cell.playButton .addTarget(self, action:Selector("playButtonClick:"), forControlEvents: .TouchUpInside)
        cell.stopButton .addTarget(self, action:Selector("stopButtonClick:"), forControlEvents: .TouchUpInside)
        cell.playButton.tag = indexPath.row
        
        
        
        
        return cell
        
    }
    @objc private func playButtonClick(sender : UIButton!) {
        
        
        let url = NSURL(string: songUrl[sender.tag])
        print("the url = \(url!)")
        downloadFileFromURL(url!)
        
    }
    
    func downloadFileFromURL(url:NSURL){
        var downloadTask:NSURLSessionDownloadTask
        downloadTask = NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: { (URL, response, error) -> Void in
            
            self.play(URL!)
            
        })
        
        downloadTask.resume()
        
    }
    
    func play(url:NSURL) {
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
            player!.prepareToPlay()
            player!.volume = 1.0
            player!.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
    @objc private func stopButtonClick(sender : UIButton!) {
        
        
        self.player!.stop();
        
    }
    
    
    
    
    func loadImageFromUrl(url: String, view: UIImageView){
        
        // Create Url from string
        let url = NSURL(string: url)!
        
        // Download task:
        // - sharedSession = global NSURLCache, NSHTTPCookieStorage and NSURLCredentialStorage objects.
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
            // if responseData is not null...
            if let data = responseData{
                
                // execute in UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    view.image = UIImage(data: data)
                })
            }
        }
        
        // Run task
        task.resume()
    }
    
    
}


