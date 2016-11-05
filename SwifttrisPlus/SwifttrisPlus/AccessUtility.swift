//
//  AccessUtility.swift
//  SwifttrisPlus
//
//  Created by Alexandar on 11/5/16.
//  Copyright © 2016 Alexandar. All rights reserved.
//

import Foundation
import UIKit

class AccessUtility: NSObject {
    static let sharedInstance: AccessUtility = { AccessUtility() }()
    
    func voiceOverIsRunning() -> Bool {
        return UIAccessibilityIsVoiceOverRunning()
    }
    
    func speak(thisString: String) {
        if self.voiceOverIsRunning() {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, thisString)
        }
    }
}
