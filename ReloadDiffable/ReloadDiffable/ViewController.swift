//
//  ViewController.swift
//  ReloadDiffable
//
//  Created by 강수진 on 2023/05/25.
//

import UIKit

class ViewController: UIViewController {
    
    var isExpand: Bool = false
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .red
        let nib = UINib(nibName: String(describing: "ExpandableCell"), bundle: .main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ExpandableCell")
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpandableCell",
                                                  for: indexPath) as! ExpandableCell
        cell.delegate = self
        cell.configure(isExpand: self.isExpand)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.window?.bounds.width ?? .zero,
                      height: self.isExpand ? 101 : 61)
    }
}

extension ViewController: ExpandableCellDelegate {
    func expandableCell(_ cell: ExpandableCell, didSelectExpand isExpand: Bool) {
        self.isExpand = isExpand
        let expandableCellIndexPath = [IndexPath(row: 0, section: 0)]
        self.collectionView.reloadItems(at: expandableCellIndexPath) // <--- Problem position!
        
//        cell.configure(isExpand: isExpand)
//        self.collectionView.collectionViewLayout.invalidateLayout()
        
    }
}
