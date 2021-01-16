//
//  ActivityIndicator.swift
//  CompositionalListExample
//
//  Created by James Rochabrun on 1/11/21.
//

import SwiftUI
import CompositionalList

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    }
}


struct ContentViewWrapper<Content: Parent>: UIViewRepresentable {
        
    func makeUIView(context: Context) -> UIView {
        ContentViewWrappperViewController<Content>().view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

import UIKit

class ContentViewWrappperViewController<Content: Parent>: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController<Content?>(rootView: nil)
        let conView = Content(parent: hostingController)
        hostingController.rootView = conView
        addChild(hostingController)
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}

protocol Parent: View {
    var parent: UIViewController { get }
    init(parent: UIViewController)
}
