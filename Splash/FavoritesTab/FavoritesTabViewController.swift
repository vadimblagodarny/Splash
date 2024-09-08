//
//  FavoritesTabViewController.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

private enum Constants {
    static let cellId = "FavoritePhotoCell"
    static let collectionViewSpacing: CGFloat = 10
    static let itemsInRow: CGFloat = 2
    static let editEditTitle = "Edit"
    static let editDoneTitle = "Done"
}

final class FavoritesTabViewController: UIViewController {
    private let viewModel: FavoritesTabViewModel
    
    private let collectionView: UICollectionView = {
        let itemSize = ((UIScreen.main.bounds.width - GlobalConstants.Sizes.screenPadding * 2) / Constants.itemsInRow) - Constants.collectionViewSpacing
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = Constants.collectionViewSpacing
        layout.minimumInteritemSpacing = Constants.collectionViewSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let refreshControl = UIRefreshControl()
    
    init(viewModel: FavoritesTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFavoritePhotos()
    }
    
    private func setupBindings() {
        viewModel.favoritePhotos.bind { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        viewModel.error.bind { [weak self] errorMessage in
            guard let self else { return }
            guard let errorMessage else { return }
            CustomAlert.showErrorAlert(on: self,
                                       message: errorMessage,
                                       retryHandler: self.viewModel.fetchFavoritePhotos)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.editEditTitle,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(toggleEditMode))
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.register(FavoritePhotoCell.self, forCellWithReuseIdentifier: Constants.cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                constant: GlobalConstants.Sizes.screenPadding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: GlobalConstants.Sizes.screenPadding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                     constant: -GlobalConstants.Sizes.screenPadding),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -GlobalConstants.Sizes.screenPadding)
        ])
    }
    
    @objc private func handleRefresh() {
        viewModel.fetchFavoritePhotos()
        refreshControl.endRefreshing()
    }
    
    @objc private func toggleEditMode() {
        collectionView.isEditing.toggle()
        navigationItem.rightBarButtonItem?.title = collectionView.isEditing ? Constants.editDoneTitle : Constants.editEditTitle
        collectionView.reloadData()
    }
}

extension FavoritesTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favoritePhotos.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId, for: indexPath) as! FavoritePhotoCell
        let photo = viewModel.favoritePhotos.value[indexPath.item]
        cell.configure(with: photo, isEditing: collectionView.isEditing)
        cell.deleteAction = { [weak self] in
            FavoritesManager.shared.removeFavoritePhotoID(photo.id)
            self?.viewModel.fetchFavoritePhotos()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.favoritePhotos.value[indexPath.item]
        let detailsVC = Builder().createDetailsVC(photo: photo)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
