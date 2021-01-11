//
//  HostView.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/10/21.
//

import UIKit
import SwiftUI

/// UIView abstraction that hosts a SwfitUI `View`

@available(iOS 13, *)
final public class HostView<V: View>: UIView {
    
    private weak var controller: UIHostingController<V>?
    
    public init(parent: UIViewController?, view: V) {
        super.init(frame: .zero)
        host(view, in: parent)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func host(_ view: V, in parent: UIViewController?) {
    
        defer { controller?.view.invalidateIntrinsicContentSize() }
        
        if let controller = controller {
            controller.rootView = view
        } else {
            let hostingController = UIHostingController(rootView: view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            controller = hostingController
            parent?.addChild(hostingController)
            addSubview(hostingController.view)
            NSLayoutConstraint.activate ([
                hostingController.view.topAnchor.constraint(equalTo: topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
            hostingController.didMove(toParent: parent)
        }
    }
}

