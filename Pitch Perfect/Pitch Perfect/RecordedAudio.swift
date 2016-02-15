//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Shawn Burlew on 2/2/16.
//  Copyright © 2016 Shawn Burlew. All rights reserved.
//

import UIKit

class RecordedAudio: NSObject {
  var filePathURL: NSURL!
  var title: String!
  
  init(filePathURL: NSURL, title: String) {
    self.filePathURL = filePathURL
    self.title = title
  }
}
