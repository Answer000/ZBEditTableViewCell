//
//  ZBEditTableViewCell.swift
//  ZBDelectTableViewCell
//
//  Created by Coder_Answer on 2018/3/28.
//  Copyright © 2018年 澳蜗科技. All rights reserved.
//

import UIKit

// MARK:- 数据源代理
@objc protocol EditTableViewCellDataSource : NSObjectProtocol {
    /*
     cell       ZBEditTableViewCell对象
     return     按钮的个数
     */
    func numberOfItems(in cell: ZBEditTableViewCell) -> Int
    
    /*
     cell       ZBEditTableViewCell对象
     index      按钮的下标值
     return     按钮对象
     */
    func editTableViewCell(_ cell: ZBEditTableViewCell, itemForIndex index: Int) -> UIButton
    
    /*
     cell       ZBEditTableViewCell对象
     return     按钮宽度(默认70)
     */
    @objc optional func widthForItem(in cell: ZBEditTableViewCell) -> CGFloat
    
    /*
     cell       ZBEditTableViewCell对象
     index      选择按钮的下标值
     */
    @objc optional func editTableViewCell(_ cell: ZBEditTableViewCell, didSelectItemAt index: Int)
}

class ZBEditTableViewCell: UITableViewCell {
    
    // 按钮的容器视图
    fileprivate lazy var itemContainerView : UIView = {
        let view = UIView.init()
        self.insertSubview(view, belowSubview: self.contentView)
        view.isHidden = true
        return view
    }()
    
    // 滑动手势
    fileprivate lazy var pan : UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognizerAction(sender:)))
        pan.delegate = self
        return pan
    }()
    
    // 点击手势
    fileprivate  lazy var tap : UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGestureRecognizerAction(sender:)))
        return tap
    }()
    
    // 是否处于删除状态
    fileprivate var isEditingState : Bool = false
    
    // 是否正在执行动画
    fileprivate var isAnimation : Bool = false
    
    // 按钮的宽度（默认70）
    fileprivate var itemWidth : CGFloat = 70
    
    // itemContainerView宽度
    fileprivate var itemContainerViewWidth : CGFloat = 0
    
    // 复原上一个cell的回调
    public var rehabilitateLastCellClosure : ((_ lastCell : ZBEditTableViewCell?) -> ())?
    
    // 编辑按钮的数据源代理
    public var dataSource : EditTableViewCellDataSource? {
        didSet{
            guard let dataSource = dataSource else { return }
            
            if dataSource.responds(to: #selector(dataSource.numberOfItems(in:))) == false {
                assert(false, "dataSource.numberOfItems(in:) not implementation")
                return
            }
            
            if dataSource.responds(to: #selector(dataSource.editTableViewCell(_:itemForIndex:))) == false {
                assert(false, "dataSource.editTableViewCell(_:itemForIndex:) not implementation")
                return
            }
            
            let number = dataSource.numberOfItems(in: self)
            if number == 0 { return }
            
            if dataSource.responds(to: #selector(dataSource.widthForItem(in:))) {
                if let width = dataSource.widthForItem?(in: self) {
                    itemWidth = width
                }
            }
            
            self.itemContainerViewWidth = CGFloat(number) * itemWidth
            
            for i in 0..<number {
                let item = dataSource.editTableViewCell(self, itemForIndex: i)
                item.addTarget(self, action: #selector(itemAction(sender:)), for: UIControlEvents.touchUpInside)
                item.tag = i
                self.itemContainerView.addSubview(item)
            }
            
            // 添加滑动手势
            self.addGestureRecognizer(self.pan)
        }
    }

    // MARK:- 构造函数
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.contentView.backgroundColor = UIColor.white
    }
    
    // MARK:- 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let dataSource = dataSource else {
            return
        }
        if dataSource.numberOfItems(in: self) > 0 {
            self.itemContainerView.frame.size = CGSize.init(width: itemContainerViewWidth, height: self.bounds.height)
            self.itemContainerView.frame.origin = CGPoint.init(x: self.bounds.width - itemContainerViewWidth, y: 0)
            
            for (index, item) in self.itemContainerView.subviews.enumerated() {
                item.frame.size = CGSize.init(width: itemWidth, height: self.itemContainerView.bounds.height)
                item.frame.origin = CGPoint.init(x: CGFloat(index) * itemWidth, y: 0)
            }
        }
    }
}

extension ZBEditTableViewCell {
    // MARK:- 点击手势监听方法
    @objc private func tapGestureRecognizerAction(sender : UIPanGestureRecognizer?) {
        self.isSelected = false
        if isAnimation { return }
        isAnimation = true
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.2,
                       options: .curveEaseInOut,
                       animations:{
                        self.contentView.frame.origin.x = 0
        }, completion: { (finished) in
            self.isEditingState = false
            self.isAnimation = false
            self.itemContainerView.isHidden = true
            self.removeGestureRecognizer(self.tap)
        })
    }
    
    // MARK:- 滑动手势监听方法
    @objc private func panGestureRecognizerAction(sender : UIPanGestureRecognizer) {
        
        let offsetPoint = sender.translation(in: self)
        if isEditingState {
            self.tapGestureRecognizerAction(sender: self.gestureRecognizers?.last as? UIPanGestureRecognizer)
            return
        }
        
        if sender.state == UIGestureRecognizerState.began {
            self.isSelected = false
            self.itemContainerView.isHidden = false
            self.rehabilitateLastCellClosure?(self)
            self.addGestureRecognizer(self.tap)
            
        }else if sender.state == UIGestureRecognizerState.changed {
            
            if  fabsf(Float(offsetPoint.y)) < 5,
                self.contentView.frame.origin.x <= 0,
                self.contentView.frame.origin.x > -(itemContainerViewWidth + 20),
                offsetPoint.x < 0 {
                let xValue = self.contentView.frame.origin.x + offsetPoint.x
                self.contentView.frame.origin.x = xValue
            }
            
        }else if sender.state == UIGestureRecognizerState.ended {
            var x : CGFloat = 0
            if self.contentView.frame.origin.x < -itemWidth/2 {
                x = -itemContainerViewWidth
                isEditingState = true
            }else{
                self.itemContainerView.isHidden = true
                isEditingState = false
                self.removeGestureRecognizer(self.tap)
            }
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0.2,
                           options: .curveEaseInOut,
                           animations:
                {
                    self.contentView.frame.origin.x = x
            }, completion: { (finished) in
                
            })
        }
        
        // 复位
        sender.setTranslation(.zero, in: self)
    }
    
    // MARK:- 按钮监听方法
    @objc private func itemAction(sender: UIButton) {
        self.closeAnimation()
        dataSource?.editTableViewCell?(self, didSelectItemAt: sender.tag)
    }
}


extension ZBEditTableViewCell {
    // MARK:- 关闭cell,结束编辑状态
    fileprivate func closeAnimation() {
        self.tapGestureRecognizerAction(sender: self.gestureRecognizers?.last as? UIPanGestureRecognizer)
    }
    
    // MARK:- 复原上一个cell
    public func rehabilitateLastCell(cell : ZBEditTableViewCell?) {
        if let cell = cell {
            if cell.isEditingState || cell.isSelected {
                cell.closeAnimation()
                cell.isSelected = false
            }
        }
    }
}


extension ZBEditTableViewCell {
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 解决滑动手势与UIScrollView滚动手势的冲突
        if  self.pan != otherGestureRecognizer,
            self.tap != otherGestureRecognizer,
            self.contentView.frame.origin.x < -2 {
            return false
        }
        return true
    }
}

