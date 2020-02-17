//
//  Enums.swift
//  Miio
//
//  Created by Maksim Kolesnik on 15/02/2020.
//

import Foundation

public enum HumidifierMode: String, ParamsConverible, Codable {
    case silent
    case medium
    case high
    case auto
}

public enum PurifierMode: String, ParamsConverible, Codable {
    case idle
    case auto
    case silent
    case favorite
}

public enum Active: String, ParamsConverible, Codable {
    case on
    case off
}
