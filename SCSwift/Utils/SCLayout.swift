//
//  SCLayout.swift
//  scswift-example
//
//  Created by Nicola Innocenti on 15/01/22.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import Foundation
import UIKit

public enum SCLayoutEdge {
    case left
    case top
    case right
    case bottom
    case leading
    case trailing
}

public enum SCLayoutDimension {
    case width
    case height
}

public enum SCLayoutAxis {
    case vertical
    case horizontal
}

public enum SCLayoutRelation {
    case greaterOrEqual
    case lesserOrEqual
    case equal
}

public extension UIView {
    // MARK: - View to View Edges
    @discardableResult func sc_pinEdge(_ edge: SCLayoutEdge, toEdge: SCLayoutEdge, ofView: UIView, withOffset: CGFloat = 0, withRelation: SCLayoutRelation = .equal) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint!
        let startAnchorIsX = edge == .trailing || edge == .leading || edge == .left || edge == .right
        let endingAnchorIsX = toEdge == .trailing || toEdge == .leading || toEdge == .left || toEdge == .right
        
        if startAnchorIsX != endingAnchorIsX {
            fatalError("[SCLayout] Can\'t anchor edge \(edge) to edge \(toEdge)")
        }
        
        if startAnchorIsX && endingAnchorIsX {
            let startingAnchor = getXAnchorByEdge(edge: edge, ofView: self)
            let endingAnchor = getXAnchorByEdge(edge: toEdge, ofView: ofView)
            switch withRelation {
                case .greaterOrEqual:
                    constraint = startingAnchor.constraint(greaterThanOrEqualTo: endingAnchor, constant: withOffset)
                case .lesserOrEqual:
                    constraint = startingAnchor.constraint(lessThanOrEqualTo: endingAnchor, constant: withOffset)
                case .equal:
                    constraint = startingAnchor.constraint(equalTo: endingAnchor, constant: withOffset)
            }
        } else if !startAnchorIsX && !endingAnchorIsX {
            let startingAnchor = getYAnchorByEdge(edge: edge, ofView: self)
            let endingAnchor = getYAnchorByEdge(edge: toEdge, ofView: ofView)
            switch withRelation {
                case .greaterOrEqual:
                    constraint = startingAnchor.constraint(greaterThanOrEqualTo: endingAnchor, constant: withOffset)
                case .lesserOrEqual:
                    constraint = startingAnchor.constraint(lessThanOrEqualTo: endingAnchor, constant: withOffset)
                case .equal:
                    constraint = startingAnchor.constraint(equalTo: endingAnchor, constant: withOffset)
            }
        }
        NSLayoutConstraint.activate([constraint])
        return constraint
    }
    
    // MARK: - View to SuperView Edges
    @discardableResult func sc_pinEdge(toSuperViewEdge: SCLayoutEdge, withOffset: CGFloat = 0, withRelation: SCLayoutRelation = .equal) -> NSLayoutConstraint {
        guard let sup = superview else {
            fatalError("[SCLayout] Can\'t anchor edge \(toSuperViewEdge) to edge \(toSuperViewEdge) because superview is nil")
        }
        return sc_pinEdge(toSuperViewEdge, toEdge: toSuperViewEdge, ofView: sup, withOffset: withOffset, withRelation: withRelation)
    }
    
    func sc_pinEdgesToSuperViewEdges(withInsets: UIEdgeInsets = .zero, exceptEdge: SCLayoutEdge? = nil) {
        guard let sup = superview else {
            fatalError("[SCLayout] Can\'t anchor edges to superview because superview is nil")
        }
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if let noEdge = exceptEdge {
            if noEdge != .top {
                constraints.append(topAnchor.constraint(equalTo: sup.topAnchor, constant: withInsets.top))
            }
            if noEdge != .left {
                constraints.append(leadingAnchor.constraint(equalTo: sup.leadingAnchor, constant: withInsets.left))
            }
            if noEdge != .bottom {
                constraints.append(bottomAnchor.constraint(equalTo: sup.bottomAnchor, constant: withInsets.bottom))
            }
            if noEdge != .right {
                constraints.append(trailingAnchor.constraint(equalTo: sup.trailingAnchor, constant: withInsets.right))
            }
        } else {
            constraints.append(contentsOf: [
                topAnchor.constraint(equalTo: sup.topAnchor, constant: withInsets.top),
                leadingAnchor.constraint(equalTo: sup.leadingAnchor, constant: withInsets.left),
                bottomAnchor.constraint(equalTo: sup.bottomAnchor, constant: withInsets.bottom),
                trailingAnchor.constraint(equalTo: sup.trailingAnchor, constant: withInsets.right)
            ])
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Dimensions
    @discardableResult func sc_setDimension(_ dimension: SCLayoutDimension, withValue: CGFloat, withRelation: SCLayoutRelation = .equal) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint!
        if dimension == .width {
            switch withRelation {
                case .equal:
                    constraint = widthAnchor.constraint(equalToConstant: withValue)
                case .greaterOrEqual:
                    constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: withValue)
                case .lesserOrEqual:
                    constraint = widthAnchor.constraint(lessThanOrEqualToConstant: withValue)
            }
        } else {
            switch withRelation {
                case .equal:
                    constraint = heightAnchor.constraint(equalToConstant: withValue)
                case .greaterOrEqual:
                    constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: withValue)
                case .lesserOrEqual:
                    constraint = heightAnchor.constraint(lessThanOrEqualToConstant: withValue)
            }
        }
        NSLayoutConstraint.activate([constraint])
        return constraint
    }
    
    func sc_setSize(_ size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(widthAnchor.constraint(equalToConstant: size.width))
        constraints.append(heightAnchor.constraint(equalToConstant: size.height))
        NSLayoutConstraint.activate(constraints)
    }
    
    func sc_MatchDimension(_ dimension: SCLayoutDimension, toDimension: SCLayoutDimension, ofView: UIView, relation: SCLayoutRelation = .equal) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        let startingAnchor = dimension == .width ? widthAnchor : heightAnchor
        let endingAnchor = toDimension == .width ? ofView.widthAnchor : ofView.heightAnchor
        switch relation {
            case .greaterOrEqual:
                constraints.append(startingAnchor.constraint(greaterThanOrEqualTo: endingAnchor))
            case .lesserOrEqual:
                constraints.append(startingAnchor.constraint(lessThanOrEqualTo: endingAnchor))
            case .equal:
                constraints.append(startingAnchor.constraint(equalTo: endingAnchor))
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Axis
    func sc_alignAxisToSuperview(axis: SCLayoutAxis, withOffset: CGFloat = 0) {
        guard let sup = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if axis == .vertical {
            constraints.append(centerYAnchor.constraint(equalTo: sup.centerYAnchor, constant: withOffset))
        } else {
            constraints.append(centerXAnchor.constraint(equalTo: sup.centerXAnchor, constant: withOffset))
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func sc_alignAxis(axis: SCLayoutAxis, toView: UIView, withOffset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if axis == .vertical {
            constraints.append(centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: withOffset))
        } else {
            constraints.append(centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: withOffset))
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func sc_alignAxisToSuperviewAxis() {
        guard let sup = superview else { return }
        var constraints = [NSLayoutConstraint]()
        constraints.append(centerXAnchor.constraint(equalTo: sup.centerXAnchor, constant: 0))
        constraints.append(centerYAnchor.constraint(equalTo: sup.centerYAnchor, constant: 0))
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Utilities
    private func getXAnchorByEdge(edge: SCLayoutEdge, ofView: UIView) -> NSLayoutXAxisAnchor {
        var anchor: NSLayoutXAxisAnchor!
        switch edge {
            case .left:
                anchor = ofView.leftAnchor
            case .right:
                anchor = ofView.rightAnchor
            case .leading:
                anchor = ofView.leadingAnchor
            case .trailing:
                anchor = ofView.trailingAnchor
            default:
                anchor = ofView.leadingAnchor
        }
        return anchor
    }
    
    private func getYAnchorByEdge(edge: SCLayoutEdge, ofView: UIView) -> NSLayoutYAxisAnchor {
        var anchor: NSLayoutYAxisAnchor!
        switch edge {
            case .top:
                anchor = ofView.topAnchor
            case .bottom:
                anchor = ofView.bottomAnchor
            default:
                anchor = ofView.topAnchor
        }
        return anchor
    }
}
