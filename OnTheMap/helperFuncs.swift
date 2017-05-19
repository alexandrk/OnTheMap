//
//  helperFuncs.swift
//  OnTheMap
//
//  Created by Alexander on 5/15/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation

/**
    Performs UI updates on Main (used in async calls)
 */
func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
