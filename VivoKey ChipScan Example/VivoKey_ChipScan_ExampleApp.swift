//
//  VivoKey_ChipScan_ExampleApp.swift
//  VivoKey ChipScan Example
//
//  Created by Ryuuzaki on 2021/02/16.
//

import SwiftUI


@main
struct VivoKey_ChipScan_ExampleApp: App {


let reader = Reader()

    var body: some Scene {
        WindowGroup {
            ContentView()
               .environmentObject(reader)
        }
    }
}
