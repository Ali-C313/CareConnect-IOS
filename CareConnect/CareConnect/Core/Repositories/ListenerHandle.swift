//
//  ListenerHandle.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Laufender Live-Listener, mit remove() beenden
protocol ListenerHandle: AnyObject {
    func remove()
}

/// Listener für die Mock-Repositories, macht nichts
final class MockListener: ListenerHandle {
    func remove() {}
}
