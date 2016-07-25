//
//  ShowSongsViewModel.swift
//  ITunesAudioPlayerApp
//
//  Created by Kingfisher on 7/25/16.
//  Copyright © 2016 dahlia. All rights reserved.
//

import Foundation

protocol SongsDetailsResponseDelegate {
    
    func setSongsDetailsResponseDetails(songsDetails : [ShowSongsViewModel],httpResponsCode: Int)
    
}

class ShowSongsViewModel {
    
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.config)
    
    var songsDetailsList = [ShowSongsViewModel]()
    var songsDetailsArray = []
    
    var delegate : SongsDetailsResponseDelegate?
    
    var songModel : SongModel?
    var showSongsViewModel : ShowSongsViewModel?
    
    
    var artistName : String?
    var trackName : String?
    var time : String?
    var price : String?
    var releaseDate : String?
    var imageUrl : String?
    var songPlayUrl : String?
    
    init(){
        
    }
    
    
    init(artistName:String,trackName:String,time:String,price:String,releaseDate:String,imageUrl:String,songPlayUrl:String){
        
        self.artistName = artistName
        self.trackName = trackName
        self.time = time
        self.price = price
        self.releaseDate = releaseDate
        self.imageUrl = imageUrl
        self.songPlayUrl = songPlayUrl
        
        
    }
    
    
    
    
    
    
    func getJSONFromRequest() {
        
        let url = NSURLComponents(string: UrlConstant.ITUNES_SONGS_LIST_MAIN_URL)!
        
        var jsonDictionary = NSDictionary()
        var httpResponseCode : Int?
        
        if let combineUrl = url.URL {
            
            let request = NSURLRequest(URL: combineUrl)
            let dataTask = session.dataTaskWithRequest(request) {
                (let data, let response, let error) in
                
                // 1. Check HTTP response for successful GET request
                if let httpResponse = response as? NSHTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        // 2. Create JSON object with data
                        jsonDictionary = ((try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? NSDictionary)!
                        
                        httpResponseCode = httpResponse.statusCode
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if self.delegate != nil {
                                
                                self.songsDetailsArray = jsonDictionary.objectForKey("results") as! NSArray
                                
                                for var i = 0 ; i < self.songsDetailsArray.count ; i++ {
                                    let tempdata = self.songsDetailsArray[i] as! NSDictionary
                                    self.songModel = SongModel(artistName:tempdata.objectForKey("artistName") as! String, trackName: tempdata.objectForKey("trackName") as! String, time: (tempdata.objectForKey("trackTimeMillis")?.integerValue)!, price: (tempdata.objectForKey("trackPrice")?.doubleValue)!, releaseDate: tempdata.objectForKey("releaseDate") as! String, imageUrl: tempdata.objectForKey("artworkUrl100") as! String, songPlayUrl: tempdata.objectForKey("previewUrl") as! String);
                                    
                                    let str = self.songModel!.releaseDate!
                                    let dateString = str[str.startIndex.advancedBy(0)...str.startIndex.advancedBy(9)]
                                    
                                    
                                    
                                    self.showSongsViewModel = ShowSongsViewModel(artistName: self.songModel!.artistName!, trackName: self.songModel!.trackName!, time: self.convertTimeInMinutesSeconds(self.songModel!.time!), price: String(self.songModel!.price!), releaseDate:dateString , imageUrl: self.songModel!.imageUrl!, songPlayUrl: self.songModel!.songPlayUrl!)
                                    self.songsDetailsList.append(self.showSongsViewModel!)
                                }
                                
                                
                                self.delegate?.setSongsDetailsResponseDetails(self.songsDetailsList,httpResponsCode: httpResponseCode!)
                                
                            }
                        })
                        
                        
                        
                    default:
                        print("GET request not successful. HTTP status code: \(httpResponse.statusCode)")
                    }
                } else {
                    print("Error: Not a valid HTTP response")
                }
            }
            
            dataTask.resume()
        }
    }
    
    
    
    
    
    
    func convertTimeInMinutesSeconds(seconds : Int) -> String {
        var time : String?
        let second = (seconds/60 % 60)
        let minutes = seconds % 06
        
        time = "\(minutes):\(second)"
        
        return time!
    }
    
    
    
    
}

