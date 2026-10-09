//
//  MaintenanceManager.swift
//  SideStore
//
//  Created by Magesh K on 22/08/26.
//  Copyright © 2026 SideStore. All rights reserved.
//

import Foundation
import SideSign

public final class MaintenanceManager {
    public static let shared = MaintenanceManager()

    // Increment this counter whenever you want to trigger another maintenance pass in future updates
    public static let currentMaintenanceCounter = 3

    public static let maintenanceCounterFileName = ".maintenance_counter"

    private var maintenanceCounterFileURL: URL? {
        // Free-account sideloads are signed without the App Group entitlement, so
        // altstoreSharedDirectory is nil and the counter could never be persisted. As a result
        // completedCounter always read 0 and every cold launch re-ran pass 1, which clears the
        // Keychain and signs the user out. Fall back to a per-app writable directory so the
        // counter persists and maintenance runs at most once.
        if let sharedDirectory = FileManager.default.altstoreSharedDirectory {
            return sharedDirectory.appendingPathComponent(Self.maintenanceCounterFileName)
        }

        guard let fallbackDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        try? FileManager.default.createDirectory(at: fallbackDirectory, withIntermediateDirectories: true)
        return fallbackDirectory.appendingPathComponent(Self.maintenanceCounterFileName)
    }

    private var completedCounter: Int {
        get {
            guard let url = maintenanceCounterFileURL,
                  let str = try? String(contentsOf: url, encoding: .utf8),
                  let val = Int(str.trimmingCharacters(in: .whitespacesAndNewlines)) else { return 0 }
            return val
        }
        set {
            guard let url = maintenanceCounterFileURL else { return }
            try? "\(newValue)".write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private init() {}

    public func performMaintenanceIfNeeded() {
        let current = completedCounter
        guard current < Self.currentMaintenanceCounter else { return }

        for pass in (current + 1)...Self.currentMaintenanceCounter {
            debugLog("[MaintenanceManager] Running maintenance pass \(pass)...")
            switch pass {
            case 1:
                Keychain.shared.clearAll()
                AuthManager.shared.signOut(keepCertificate: false, keepAnisetteData: false)
            case 2:
                AnisetteDataManager.shared.clearCache()
                AuthManager.shared.signOut(keepCertificate: true, keepAnisetteData: false)
            case 3:
                UserDefaults.standard.tunnelOverridePeerIp = nil
            default:
                break
            }
        }

        completedCounter = Self.currentMaintenanceCounter
        debugLog("[MaintenanceManager] Maintenance up to counter \(Self.currentMaintenanceCounter) complete.")
    }
}
