//
//  ContentViewWrappperViewController.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/16/21.
//

import Foundation
import UIKit
import SwiftUI

final public class ContentViewWrappperViewController<Content: Parent>: UIViewController {
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController<Content?>(rootView: nil)
        let conView = Content(parent: hostingController)
        hostingController.rootView = conView
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
