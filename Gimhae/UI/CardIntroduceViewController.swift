import Foundation
import UIKit
import Cards
import Combine

class CardIntroduceViewController: UIViewController {
    private var collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var core = CardIntroduceCore()
    private var subscription = Set<AnyCancellable>()
    private var segment = LargeSegmentView([
        .init(title: "축제 정보"),
        .init(title: "핫플 (준비중)")
    ])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        bind(core: self.core)
    }
    
    private func initView() {
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .systemBackground
        view.add(segment) {
            $0.backgroundColor = .systemBackground
            $0.segmentedControl.selectedSegmentIndex = 0
//            $0.segmentedControl.isEnabled = false
            $0.snp.makeConstraints { make in
                make.top.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
                make.height.equalTo(52)
            }
        }
        view.add(collectionView) {
            $0.delegate = self
            $0.dataSource = self
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.segment.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
            $0.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.id)
        }
    }
    
    private func bind(core: CardIntroduceCore) {
        core.$state.map(\.models)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] models in
                self?.collectionView.reloadData()
            }
            .store(in: &subscription)
    }
}


extension CardIntroduceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.core.state.models.first?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let firstModel = self.core.state.models.first {
            switch firstModel.items[indexPath.row] {
            case let .festival(value):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.id, for: indexPath) as! CardCollectionViewCell
                let festival = CardDetailViewController(festival: value)
                cell.configure(festival: value, vc: festival, parent: self)
                return cell
                
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = CGFloat(16)
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 2 // 셀 하나의 너비
        let height: CGFloat = width + 32
        return CGSize(width: width, height: height)
    }
    
    
}

class CardCollectionViewCell: UICollectionViewCell {
    static let id = "CardCollectionViewCell"
    let card = CardHighlight()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        contentView.backgroundColor = .clear
        contentView.add(card){
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func configure(festival: Festival, vc: UIViewController, parent: UIViewController) {
        if let _image = festival.images.first, let url = URL(string: _image) {
            Task {
                if let image = try? await ImageDownloader.shared.image(from: url) {
                    if image.brightness > 30 {
                        self.card.textColor = .white

                    } else if image.brightness < 30 {
                        self.card.textColor = .black
                    } else {
                        self.card.textColor = .gray
                    }
                    self.card.setNeedsDisplay()
                    
                    self.card.backgroundImage = image
                }
            }
        }

        
        card.hasParallax = true
        card.title = ""
        card.itemTitle = festival.area
        card.itemSubtitle = festival.name
        card.shouldPresent(vc, from: parent, fullscreen: true)
        card.buttonText = "자세히"
        self.card.setNeedsDisplay()
    }
}


extension UIImage {
    func with(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
