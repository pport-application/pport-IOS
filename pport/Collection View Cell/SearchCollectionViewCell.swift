//
//  SearchCollectionViewCell.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 28.02.2022.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var exchangeLabel: UILabel!
    
    
    var delegate: SearchCollectionViewCellDelegate?
    var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    @IBAction func addBtnTapped(_ sender: Any) {
        guard let indexPath = indexPath else {
            return
        }
        self.delegate?.didSelected(indexPath: indexPath)
    }
    
    func setLabels(data: SearchData) {
        self.symbolLabel.text = data.Code
        self.nameLabel.text = data.Name
        self.exchangeLabel.text = data.Type
        self.addBtn.setTitle("", for: .normal)
    }
    
    func setPath(with indexPath: IndexPath?) {
        self.indexPath = indexPath
    }
}
