//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Demain Petropavlov on 25.02.2025.
//

import Testing
import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    func testTrackerViewController() {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)))
    }
    
    func testTrackerViewControllerDarkTheme() {
        let vc = TrackerViewController()
        assertSnapshot(of: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)))
    }
    
    func testViewController() {
        let vc = TrackerViewController()
        
        assertSnapshot(matching: vc, as: .image)                                             // 2
    }
}
