//
//  IGZLocationError.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

open class IGZLocationError: NSError {

    fileprivate(set) var region: CLRegion?

    public convenience init(_ error: Error) {
        self.init(error: error as NSError, region: nil)
    }

    public convenience init(_ error: Error, region: CLRegion? = nil) {
        self.init(error: error as NSError, region: nil)
    }

    public convenience init(error: NSError) {
        self.init(error, region: nil)
    }

    public init(error: NSError, region: CLRegion? = nil) {
        var userInfo = error.userInfo
        userInfo[NSUnderlyingErrorKey] = error
        super.init(domain: error.domain, code: error.code, userInfo: userInfo)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open var underlyingError: NSError? {
        return userInfo[NSUnderlyingErrorKey] as? NSError
    }
    
}
