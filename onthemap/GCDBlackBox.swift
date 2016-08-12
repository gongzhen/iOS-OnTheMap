//
//  GCDBlackBox.swift
//  onthemap
//
//  Created by gongzhen on 3/20/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import Foundation

func performUIUpdatedsOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}
