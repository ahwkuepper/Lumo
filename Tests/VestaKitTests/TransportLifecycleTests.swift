// Copyright 2026 Andreas Kupper
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import VestaKit

private actor LifecycleTransport: LightTransport {
    private var handlers: [@MainActor (TransportEvent) -> Void] = []
    private(set) var stopCount = 0
    private(set) var refreshCount = 0

    func start(handler: @escaping @MainActor (TransportEvent) -> Void) async {
        handlers.append(handler)
    }
    func stop() async { stopCount += 1 }
    func refreshAvailability() async { refreshCount += 1 }
    func send(_ availability: TransportAvailability, session: Int) async {
        await handlers[session](.availabilityChanged(availability))
    }
    func setPower(_ on: Bool, for id: Light.ID) async throws {}
    func setBrightness(_ brightness: Double, for id: Light.ID) async throws {}
    func setColor(_ color: LightColor, for id: Light.ID) async throws {}
}

@Suite("Transport lifecycle")
@MainActor
struct TransportLifecycleTests {
    @Test("Rechecking availability recovers the current store without losing its lights")
    func recovery() async {
        let transport = LifecycleTransport()
        let lights = SimulatedTransport.demoLights
        let store = LightStore(transport: transport, initialLights: lights)
        await store.start()
        await transport.send(.unsupported, session: 0)
        #expect(store.availability == .unsupported)
        await store.refreshAvailability()
        #expect(await transport.refreshCount == 1)
        await transport.send(.ready, session: 0)
        #expect(store.availability == .ready)
        #expect(store.lights.map(\.id) == lights.map(\.id))
    }

    @Test("Stopping shuts down the transport and ignores late events from that session")
    func ignoresRetiredSession() async {
        let transport = LifecycleTransport()
        let store = LightStore(transport: transport)
        await store.start()
        await store.stop()
        #expect(await transport.stopCount == 1)
        await transport.send(.unsupported, session: 0)
        #expect(store.availability == .ready)
        await store.start()
        await transport.send(.poweredOff, session: 1)
        await transport.send(.unsupported, session: 0)
        #expect(store.availability == .poweredOff)
    }
}
