import Foundation
import UIKit
import FSPagerView

class CardDetailViewController: UIViewController {
    private let festival: Festival
    private let pagerView: FSPagerView = .init()
    private let titleLabel = UILabel()
    private let copyLabel = UILabel()
    private let addressLabel = UILabel()
    
    
    init(festival: Festival) {
        self.festival = festival
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        self.configure()
    }
    
    private func initView() {
        view.backgroundColor = .systemBackground
        view.add(titleLabel) {
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 48, weight: .bold)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(32)
                make.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        view.add(addressLabel) {
            $0.numberOfLines = 2
            $0.font = .preferredFont(forTextStyle: .caption1)
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        view.add(copyLabel) {
            $0.numberOfLines = 0
            $0.font = .preferredFont(forTextStyle: .body)
            $0.snp.makeConstraints { make in
                make.top.equalTo(self.addressLabel.snp.bottom).offset(12)
                make.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        view.add(pagerView) {
            $0.delegate = self
            $0.dataSource = self
            $0.isInfinite = true
            $0.automaticSlidingInterval = 2
            $0.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            $0.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalTo(self.copyLabel.snp.bottom).offset(24)
                make.height.equalTo(248)
            }
        }
        
    }
    
    private func configure() {
        self.titleLabel.text = self.festival.name
        self.addressLabel.text = self.festival.address
        self.copyLabel.text = self.festival.copy
    }
}


extension CardDetailViewController: FSPagerViewDelegate, FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return festival.images.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        Task {
            if let imageUrl = URL(string: festival.images[index]),
               let image = try? await ImageDownloader.shared.image(from: imageUrl) {
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.image = image
                
            }
        }
        return cell
    }
}
