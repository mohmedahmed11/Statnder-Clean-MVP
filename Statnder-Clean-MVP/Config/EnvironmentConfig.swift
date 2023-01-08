//
//  EnvironmentConfig.swift
//  Statnder-Clean-MVP
//
//  Created by Mohamed Ahmed on 12/26/22.
//

import Foundation
import UIKit

enum EnvironmentConfig: String {
    case baseUrl
    case appName
    
    var value: String {
        get {
            return Bundle.main.infoDictionary![self.rawValue] as! String
        }
    }
}

let UUID_DEVICE = UIDevice.current.identifierForVendor?.uuidString
