//
//  AppVariables.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/23/23.
//

import Foundation

class AppVariables: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isShowingScanResult: Bool = false
    @Published var selectedScan: ScanResult? = nil
}
