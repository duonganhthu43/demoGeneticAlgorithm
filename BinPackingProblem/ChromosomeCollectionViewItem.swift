//
//  CollectionViewItem.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/26/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import AppKit
class LabelObject: NSObject {
    @objc
    var title:String
    
    init(title:String) {
        self.title = title
    }
}

class ChromosomeCollectionViewItem: NSCollectionViewItem {
    
    // MARK: properties
    
    var labelObject:LabelObject? {
        didSet {
            //label.stringValue = (labelObject?.title ?? "")
        }
    }
    
    var chromosomeView: NSView? {
        didSet {
            guard let chromosomeView = chromosomeView else { return }
            // create new view
            let newView = NSView()
            newView.addSubview(chromosomeView)
            //chromosomeView.autoresizingMask = [.width, .height]
            chromosomeView.autoCenterInSuperview()
            if mainStackView.detachedViews.count > 1 {
                let oldView = mainStackView.detachedViews[0]
                mainStackView.replaceSubview(oldView, with: chromosomeView)
            } else {
                mainStackView.subviews.removeAll()
                mainStackView.insertView(chromosomeView, at: 0, in: .top)
            }
        }
    }
    

    
    // MARK: view properties
    var mainStackView: NSStackView!
    
    // MARK: NSViewController
    
    override func loadView() {
        self.view = LabelCollectionViewItemView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        self.view.wantsLayer = true

        mainStackView = NSStackView(views: [])
        mainStackView.orientation = .vertical
        mainStackView.backgroundColor = NSColor.white
        self.view.addSubview(mainStackView)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            mainStackView.autoPinEdgesToSuperviewEdges()
        }
    }

}
