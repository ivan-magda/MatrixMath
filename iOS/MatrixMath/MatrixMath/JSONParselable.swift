//
//  JsonApiClient.swift
//  MatrixMath
//
//  Created by Ivan Magda on 31.03.16.
//  Copyright © 2016 Ivan Magda. All rights reserved.
//

import Foundation

protocol JSONParselable {
    static func decode(json: JSONDictionary) -> Self?
}
