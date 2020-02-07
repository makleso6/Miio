//
//  ArrayModifyExtension.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

extension Array {
    
    mutating func modify(where predicate: (Element) throws -> Bool, _ modifyElement: (_ element: inout Element) -> ()) rethrows {
        if let index = try self.firstIndex(where: predicate) {
            modify(at: index, modifyElement)
        }
    }
        
    mutating func modify(at index: Index, _ modifyElement: (_ element: inout Element) -> ()) {
        var element = self[index]
        modifyElement(&element)
        self[index] = element
    }
}


extension Array where Element: Hashable {
    mutating func modify(_ element: Element, _ modifyElement: (_ element: inout Element) -> ()) {
        if let index = firstIndex(of: element) {
            modify(at: index, modifyElement)
        }
    }
}

