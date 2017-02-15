//
//  FGDeviceSubclasses.swift
//  RCTOkkamiSdkImplementation
//
//  Created by Macbook Air on 2/14/17.
//  Copyright © 2017 michaelabadi.com. All rights reserved.
//

import Foundation
import RealmSwift

class FGDeviceGuest: FGDeviceSubclasses{
    public func type()->NSString{
        return "guest_device"
    }
}

class FGDeviceFRCD: FGDeviceSubclasses{
    public func type()->NSString{
        return "frcd"
    }
}

class FGDeviceFGCTV: FGDeviceSubclasses{
    public func type()->NSString{
        return "fgc_tv"
    }
}

class FGDeviceVirtualFRCD: FGDeviceSubclasses{
    public func type()->NSString{
        return "virtual_frcd"
    }
}


class FGDeviceSubclasses: Object {
    

}
