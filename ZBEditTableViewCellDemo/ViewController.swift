//
//  ViewController.swift
//  ZBEditTableViewCellDemo
//
//  Created by 澳蜗科技 on 2018/4/4.
//  Copyright © 2018年 Coder_Answer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = NSMutableArray.init()
    
    var currentCell : TableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TableViewCell.self))
        
        for i in 0..<10 {
            let json = ["iconName" : String.init(format: "headerFace_%d", i),
                        "title" : "总有刁民想害朕",
                        "message" : "哈哈，你达不到我~~"]
            let model = BaseModel.init(json: json)
            self.dataSource.add(model)
        }
    }

}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TableViewCell {
            
            cell.rehabilitateLastCellClosure?(self.currentCell)
            self.currentCell = cell
        }
    }
}



extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TableViewCell.self)) as? TableViewCell
        cell?.fillCellWithModel(model: self.dataSource[indexPath.row] as? BaseModel)
        cell?.addDataSource(self, indexPath: indexPath)
        cell?.rehabilitateLastCellClosure = { [weak self] (lastcell : ZBEditTableViewCell?) in
            lastcell?.rehabilitateLastCell(cell: self?.currentCell)
            self?.currentCell = lastcell as? TableViewCell
        }
        return cell!
    }
}

extension ViewController : EditTableViewCellDataSource {
    func numberOfItems(in cell: ZBEditTableViewCell,
                       cellForRowAt indexPath: IndexPath) -> Int {
        if indexPath.row == 0 {
            return 1
        }else if indexPath.row == 1{
            return 0
        }
        return 2
    }
    
    func editTableViewCell(_ cell: ZBEditTableViewCell,
                           itemForIndex index: Int,
                           cellForRowAt indexPath: IndexPath) -> UIButton {
        return {
            let item = UIButton.init(type: .custom)
            item.backgroundColor = [UIColor.blue, UIColor.red][index]
            item.setTitle(["编辑", "删除"][index], for: UIControlState.normal)
            item.setTitleColor(UIColor.white, for: UIControlState.normal)
            return item
        }()
    }
    
    func widthForItem(in cell: ZBEditTableViewCell,
                      cellForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3 {
            return 80
        }
        return 60
    }
    
    func editTableViewCell(_ cell: ZBEditTableViewCell,
                           didSelectItemAt index: Int,
                           cellForRowAt indexPath: IndexPath) {
        switch index {
        case 0:
            
            break
        case 1:
            if let indexPath = self.tableView.indexPath(for: cell) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    // 删除数据
                    self.dataSource.removeObject(at: indexPath.row)
                    // 删除cell
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.top)
                })
            }
            break
        default: break
            
        }
    }
}

