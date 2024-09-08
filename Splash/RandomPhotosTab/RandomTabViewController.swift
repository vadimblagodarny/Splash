//
//  RandomTabViewController.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

private enum Constants {
    static let cellId = "PhotoCell"
    static let collectionViewSpacing: CGFloat = 10
    static let itemsInRow: CGFloat = 3
    static let searchPlaceholder = "Search..."
}

final class RandomTabViewController: UIViewController {
    private let viewModel: RandomTabViewModelProtocol

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = Constants.searchPlaceholder
        return searchBar
    }()
    
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
    
    init(viewModel: RandomTabViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        setupBindings()
        addViews()
        setupViews()
        setupConstraints()
        viewModel.fetchRandomPhotos()
    }
    
    private func setupBindings() {
        viewModel.photos.bind { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        viewModel.error.bind { [weak self] errorMessage in
            guard let errorMessage = errorMessage else { return }
            print("Error: \(errorMessage)") // MARK: there can be alert
        }
    }
    
    private func addViews() {
        view.addSubview(collectionView)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: Constants.cellId)
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupConstraints() {
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
        viewModel.fetchRandomPhotos()
        refreshControl.endRefreshing()
    }
}

extension RandomTabViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.searchPhotos(query: query)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = String()
        searchBar.resignFirstResponder()
        viewModel.fetchRandomPhotos()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.fetchRandomPhotos()
        }
    }
}

extension RandomTabViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId, for: indexPath) as! PhotoCell
        let photo = viewModel.photos.value[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos.value[indexPath.item]
        let detailsVC = Builder().createDetailsVC(photo: photo)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
