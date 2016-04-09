//
//  Tutor.swift
//  Ingenium
//
//  Created by Varun Shenoy on 12/17/15.
//  Copyright © 2015 Varun Shenoy. All rights reserved.
//

import UIKit
import MapKit
import Parse

class Tutor: NSObject {
    var username:String = ""
    var name:String = ""
    var subject:String = ""
    var rating:Double = 0.0
    var price:String = ""
    var descrip:String = ""
    var phone:String = ""
    var coords:PFGeoPoint!
    var numberOfRatings:Double = 0.0
    var email:String = ""
}
