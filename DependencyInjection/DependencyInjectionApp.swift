//
//  DependencyInjectionApp.swift
//  DependencyInjection
//
//  Created by Christian Skorobogatow on 12/8/22.
//

import SwiftUI

@main
struct DependencyInjectionApp: App {
    var body: some Scene {
        WindowGroup {
            DependencyInjectionExample(dataService: ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!))
        }
    }
}
