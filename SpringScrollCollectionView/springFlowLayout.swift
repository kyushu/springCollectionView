//
//  springFlowLayout.swift
//  SpringScrollCollectionView
//
//  Created by morpheus on 2016/4/22.
//  Copyright © 2016年 morpheus. All rights reserved.
//

import UIKit

class springFlowLayout: UICollectionViewFlowLayout {

    let kCVCellSpacing: CGFloat = 5.0
    let kItemSize: CGFloat = 70.0
    
    var animator: UIDynamicAnimator?
    
    
    func setUpItemSize() {
        
        self.itemSize = CGSize(width: kItemSize, height: kItemSize)
        
        self.minimumInteritemSpacing = kCVCellSpacing;
        self.minimumLineSpacing = kCVCellSpacing;
        self.sectionInset = UIEdgeInsetsMake(kCVCellSpacing, kCVCellSpacing, kCVCellSpacing, kCVCellSpacing);
        
    }
    
    
    // static Layout
    override func prepareLayout() {
        print("\(#function)")
        super.prepareLayout()
        
        if animator == nil {
            // 預先為每個 cell 附加 UIAttachmentBehavior
            animator = UIDynamicAnimator(collectionViewLayout: self)
            let contentSize = self.collectionViewContentSize()
            guard let items = super.layoutAttributesForElementsInRect(CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)) else { return }
            
            for item in items {
                let spring = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
                
                spring.length = 0
                spring.damping = 0.5
                spring.frequency = 0.5
                
                animator?.addBehavior(spring)
            }
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        print("\(#function)")
        // 返回的是 animator 裡對 cell 的 Layout Attributes 計算後的結果
        return animator?.itemsInRect(rect) as? [UICollectionViewLayoutAttributes] ?? super.layoutAttributesForElementsInRect(rect)
        
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        print("\(#function)")
        // 返回的是 animator 裡對 cell 計算後的結果
        return animator?.layoutAttributesForCellAtIndexPath(indexPath) ?? super.layoutAttributesForItemAtIndexPath(indexPath)
        
    }
    
    
    // 每次 layout 發生變化時，都會呼叫 shouldInvalidateLayoutForBoundsChange
    // 手指一滑動就會layout就會改變 就會呼叫 shouldInvalidateLayoutForBoundsChange
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        
        print("\(#function)")
        
        if let collectionView = self.collectionView, animator = animator {

            /*
             collectionView.bounds = 原本的 bounds
             newBounds = 目前因為 scroll 後 collectionView.bounds
             delta 是 collectionView "目前" 跟 "原本" Y 的位置差距
             */
            
            let delta = newBounds.origin.y - collectionView.bounds.origin.y
//            print("collectionView.bounds: \(collectionView.bounds.origin.y)")
//            print("newBounds: \(newBounds.origin.y)")
            print("delta: \(delta)")
            
            /*
             計算手指跟每個 cell(item) 之間的距離
             #. 若手指跟 cell 之間的距離越遠，則 cell 移動的距離越大(所以有的 cell 離手指近的晃動較小，有的 cell 離手指遠的晃動較大)
             #. 設定 Resistace 係數，Resistance 數字越大所有 cell 移動的距離越小
             */
            
            let touchLocation = collectionView.panGestureRecognizer.locationInView(collectionView)
            print("touchLocation.y: \(touchLocation.y)")
            for behavior in animator.behaviors {
                
                if let spring = behavior as? UIAttachmentBehavior, item = spring.items.first as? UICollectionViewLayoutAttributes {
                    
                    
                    let yAnchorPoint: CGFloat = spring.anchorPoint.y
                    // 根據目前 手指 跟 cell 之間的距離 並乘上一個自訂的係數來決定要 cell 滑動的距離
                    let distanceFormTouch: CGFloat = fabs(touchLocation.y - yAnchorPoint)
//                    print("yAnchorPoint: \(yAnchorPoint)")
                    let scrollResistance: CGFloat = distanceFormTouch / 6000
                    
                    // 更新 cell 的 center
                    var center = item.center
                    // delta是正的向下
                    // delta是負的向上
                    center.y += delta * scrollResistance // 乘上一個係數
                    item.center = center
                    // update cell
                    animator.updateItemUsingCurrentState(item)
                }
            }
        }
        return false
    }
    
}

/*
 * prepareLayout                        : 取出需要 Layout 的 cell，在這裡可以做每個 cell 並通的處理
 * layoutAttributesForElementsInRect    : 根據 prepareLayout 取出需 Layout 的 cell 的 Layout Attribute 返回給
                                            UICollectionViewFlowLayout 使用
 * shouldInvalidateLayoutForBoundsChange: 當 scroll 時，會觸發 shouldInvalidateLayoutForBoundsChange，進而計算 cell 新的
                                            Layout Attribute (這裡的例子是更新 center )
 */


/*
 * initial:     計算每個 cell 的位置
 *                  REPEAT( prepareLayout() -> layoutAttributesForElementsInRect() -> prepareLayout() -> layoutAttributesForElementsInRect() )
 * 
 * scrolling:   手指滑動時
 *                  REPEAT( shouldInvalidateLayoutForBoundsChange -> REPEAT( layoutAttributesForElementsInRect -> prepareLayout() ) )
 *              手指停止滑動時
 *                  REPEAT( prepareLayout() -> layoutAttributesForElementsInRect() -> prepareLayout() -> layoutAttributesForElementsInRect() )
 */


