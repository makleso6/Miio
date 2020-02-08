//
//  DelayWorker.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 09/02/2020.
//

import Foundation

internal final class BlockGenerator<T> {
    typealias BlockType = (T) -> Void
    
    private let innerHandler: BlockType
    
    init(handler: @escaping BlockType) {
        innerHandler = handler
    }
    
    func run(_ value: T) {
        innerHandler(value)
    }
}

public protocol DelayWorker: AnyObject {
    func reset()
    func call()
    func performDelay(execute block: @escaping () -> Void)
}

public final class ReadyDelayWorker: DelayWorker {
    private var blocks: [BlockGenerator<Void>] = []
    private var flag = false
    
    public func performDelay(execute block: @escaping () -> Void) {
        if flag {
            block()
        } else {
            blocks.append(.init(handler: block))
        }
    }
    
    public func reset() {
        flag = false
    }
    
    public func call() {
        flag = true
        for block in blocks {
            block.run(())
        }
        blocks.removeAll()
    }
}
