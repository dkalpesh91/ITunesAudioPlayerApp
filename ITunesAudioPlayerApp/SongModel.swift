//
//  SongModel.swift
//  ITunesAudioPlayerApp
//
//  Created by Kingfisher on 7/25/16.
//  Copyright © 2016 dahlia. All rights reserved.
//

import Foundation

class SongModel {
    
    var artistName : String?
    var trackName : String?
    var time : Int?
    var price : Double?
    var releaseDate : String?
    var imageUrl : String?
    var songPlayUrl : String?
    
    
    init(artistName:String,trackName:String,time:Int,price:Double,releaseDate:String,imageUrl:String,songPlayUrl:String){
        
        self.artistName = artistName
        self.trackName = trackName
        self.time = time
        self.price = price
        self.releaseDate = releaseDate
        self.imageUrl = imageUrl
        self.songPlayUrl = songPlayUrl
        
        
    }
    
}
