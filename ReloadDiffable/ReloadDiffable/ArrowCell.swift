//
//  ArrowCell.swift
//  ReloadDiffable
//
//  Created by 강수진 on 2023/05/25.
//

import UIKit


protocol ArrowCellDelegate: AnyObject {
    func didTapButton(isExpand: Bool)
}

class ArrowCell: UICollectionViewCell {
    
    weak var delegate: ArrowCellDelegate?
 
    @IBOutlet weak var expandButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let downImage = UIImage(systemName: "chevron.down")
        let upImage = UIImage(systemName: "chevron.up")
        expandButton.setImage(downImage, for: .normal)
        expandButton.setImage(upImage, for: .selected)
    }
    
    @IBAction func onExpandButtonTouched(_ sender: UIButton) {
        delegate?.didTapButton(isExpand: !sender.isSelected)
    }
}
