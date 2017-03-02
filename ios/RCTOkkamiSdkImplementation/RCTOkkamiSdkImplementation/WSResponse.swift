//
//  WSResponse.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/15/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation

protocol WSResponse {
    func parseAndInitFields(response : Dictionary<String, Any>)
}
