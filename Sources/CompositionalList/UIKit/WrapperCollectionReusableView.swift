//
//  WrapperCollectionReusableView.swift
//  CompositionalList
//
//  Created by James Rochabrun on 1/10/21.
//

import UIKit
import SwiftUI

/// UICollectionReusableView abstraction that hosts a SwfitUI `View`

@available(iOS 13, *)
final public class WrapperCollectionReusableView<V: View>: UICollectionReusableView {

    private var hostView: HostView<V>?

    public func setupWith(_ view: V, parent: UIViewController?) {
        hostView = HostView<V>(parent: parent, view: view)
        guard let hostView = hostView else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostView)
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: topAnchor),
            hostView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        hostView?.removeFromSuperview()
        hostView = nil
    }
}
