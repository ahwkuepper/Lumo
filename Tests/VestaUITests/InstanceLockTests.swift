// Copyright 2026 Andreas Kupper
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import VestaUI

@Suite("Single app instance")
struct InstanceLockTests {
    @Test("Only one owner can hold the lock, and quitting permits the next launch")
    func exclusiveOwnership() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        var first = try InstanceLock.acquire(at: url)
        #expect(first != nil)
        try withExtendedLifetime(first) {
            let duplicate = try InstanceLock.acquire(at: url)
            #expect(duplicate == nil)
        }
        first = nil
        let next = try InstanceLock.acquire(at: url)
        #expect(next != nil)
        withExtendedLifetime(next) {}
    }

    @Test("A stale lock file from a crashed process does not block launch")
    func staleFile() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("old process".utf8).write(to: url)
        let lock = try InstanceLock.acquire(at: url)
        #expect(lock != nil)
        withExtendedLifetime(lock) {}
    }
}
