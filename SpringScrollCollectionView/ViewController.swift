//
//  ViewController.swift
//  SpringScrollCollectionView
//
//  Created by morpheus on 2016/4/22.
//  Copyright © 2016年 morpheus. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var springCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let cvLayout = springFlowLayout()
        cvLayout.setUpItemSize()
        cvLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        springCV = UICollectionView(frame: self.view.frame, collectionViewLayout: cvLayout)
        springCV.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "CELL")
        springCV.delegate = self
        springCV.dataSource = self
        
        self.view.addSubview(springCV)
        
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CELL", forIndexPath: indexPath)
        cell.contentView.backgroundColor = UIColor.orangeColor()
        return cell
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



