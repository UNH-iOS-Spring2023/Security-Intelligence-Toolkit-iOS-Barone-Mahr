//
//  AppVariables.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/23/23.
//
/// This file defines the variables that are used globally across the application.
import Foundation

class AppVariables: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isShowingScanResult: Bool = false
    @Published var selectedScan: ScanResult? = nil
}
