//
//  ResponseError.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import Foundation

public struct ResponseError: Error, Codable {
   
    var code: Int
    var message: String
    
    init(code: Int,
         message: String) {
        self.code = code
        self.message = message
    }
}
