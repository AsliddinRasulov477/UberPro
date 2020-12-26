//
//  WorkerPhotoCollectionCell.swift
//  Uber
//
//  Created by Asliddin Rasulov on 15/12/20.
//

import UIKit

class WorkerPhotoCollectionCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifire = "WorkerPhotoCollectionCell"
        
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 1
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
        pageControl.pageIndicatorTintColor = .label
        pageControl.backgroundColor = .clear
        return pageControl
    }()
    
    private let addPhoto: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.imageEdgeInsets = UIEdgeInsets(
            top: 8, left: 8, bottom: 8, right: 8
        )
        button.setImage(#imageLiteral(resourceName: "add").withTintColor(#colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)), for: .normal)
        return button
    }()
    
    private let removePhoto: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.imageEdgeInsets = UIEdgeInsets(
            top: 8, left: 8, bottom: 8, right: 8
        )
        button.setImage(#imageLiteral(resourceName: "trash").withTintColor(#colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)), for: .normal)
        return button
    }()
    
    private lazy var photoCollection: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: collectionViewLayout()
        )
        
        collectionView.register(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoCollectionViewCell.identifire
        )
        
        collectionView.backgroundColor = .clear
        
        collectionView.bounces = false
        collectionView.bouncesZoom = false
        collectionView.isPagingEnabled = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width
        )
            
        return layout
    }
    
    var imageCollection: [String] = []
    
    // MARK: - Lifecycle
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
    
    private func addSubviews() {
        
        selectionStyle = .none
        
        pageControl.frame = CGRect(
            x: 56, y: 0,
            width: frame.width - 112, height: 40
        )
        
        contentView.addSubview(pageControl)
        
        contentView.addSubview(addPhoto)
        addPhoto.anchor(
            top: contentView.topAnchor, right: contentView.rightAnchor,
            paddingRight: 8, width: 40, height: 40
        )
        
        contentView.addSubview(removePhoto)
        removePhoto.anchor(
            top: contentView.topAnchor, left: contentView.leftAnchor,
            paddingLeft: 8, width: 40, height: 40
        )
        
        contentView.addSubview(photoCollection)
        photoCollection.anchor(
            top: addPhoto.bottomAnchor, left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
            height: UIScreen.main.bounds.width
        )
    
        photoCollection.delegate = self
        photoCollection.dataSource = self
    }
    
  
    func configure(worker: Worker) {

        imageCollection = worker.images

        if worker.images.count != 0 {
            pageControl.currentPage = 0
            pageControl.numberOfPages = worker.images.count
        } else {
            pageControl.numberOfPages = 0
            imageCollection.append("no-image")
        }

        photoCollection.scrollToItem(
            at: IndexPath(row: 0, section: 0), at: .left, animated: false
        )
        photoCollection.reloadData()
    }
    
}

extension WorkerPhotoCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifire, for: indexPath
        ) as! PhotoCollectionViewCell
        
        cell.configure(image: imageCollection[indexPath.row])
        
        return cell
    }
}
