//
//  ContentViewWrapper.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/16/21.
//

import Foundation
import SwiftUI

/// Not adding a HostingController in a parent view controller will have unexpected layout issues.
public protocol Parent: View {
    var parent: UIViewController { get }
    init(parent: UIViewController)
}

public struct ContentViewWrapper<Content: Parent>: UIViewRepresentable {
        
    public func makeUIView(context: Context) -> UIView {
        ContentViewWrappperViewController<Content>().view
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
    }
}
