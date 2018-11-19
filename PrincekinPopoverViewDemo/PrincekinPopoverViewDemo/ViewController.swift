//
//  ViewController.swift
//  PrincekinPopoverViewDemo
//
//  Created by LEE on 11/19/18.
//  Copyright © 2018 LEE. All rights reserved.
//

import UIKit
import PrincekinPopoverView
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func upClick(_ sender: UIButton) {
              let options: [PopoverViewOption] = [.type(.up), .showBlackOverlay(false),.showShadowy(true),.arrowPositionRatio(24 / 123.0),.arrowSize(CGSize(width: 12, height: 16)),.color(.brown)]
        let pop = PrincekinPopoverView.init(options: options)
        let contentView = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        pop.contentView = contentView
        pop.show(pop.contentView, fromView: sender)
    }
    @IBAction func rightClick(_ sender: UIButton) {
        let options: [PopoverViewOption] = [.type(.right), .showBlackOverlay(false),.showShadowy(true),.arrowPositionRatio(24 / 123.0),.arrowSize(CGSize(width: 12, height: 16)),.color(.cyan)]
        let pop = PrincekinPopoverView.init(options: options)
        let contentView = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
        
        pop.contentView = contentView
        pop.show(pop.contentView, fromView: sender)
        
        
    }
    @IBAction func downClick(_ sender: UIButton) {
        let options: [PopoverViewOption] = [.type(.down), .showBlackOverlay(false),.showShadowy(true),.arrowPositionRatio(24 / 123.0),.arrowSize(CGSize(width: 12, height: 16)),.color(.purple)]
        let pop = PrincekinPopoverView.init(options: options)
        let contentView = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        pop.contentView = contentView
        pop.show(pop.contentView, fromView: sender)
        
        
        
    }
    @IBAction func leftClick(_ sender: UIButton) {
        
        let options: [PopoverViewOption] = [.type(.left), .showBlackOverlay(false),.showShadowy(true),.arrowPositionRatio(24 / 123.0),.arrowSize(CGSize(width: 12, height: 16)),.color(.orange)]
        let pop = PrincekinPopoverView.init(options: options)
        let contentView = UIView.init(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        
        pop.contentView = contentView
        pop.show(pop.contentView, fromView: sender)
        
        
        
    }
    
}

