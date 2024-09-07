//
//  RandomTabViewController.swift
//  Splash
//
//  Created by Vadim Blagodarny on 07.09.2024.
//

import UIKit

final class RandomTabViewController: UIViewController {
    private let viewModel: RandomTabViewModelProtocol

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search..."
        return searchBar
    }()
    
    private let collectionView: UICollectionView = {
        let itemSize = ((UIScreen.main.bounds.width - 40) / 3) - 10
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

extension RandomTabViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.searchPhotos(query: query)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
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
