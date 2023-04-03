import Foundation
import UIKit

class HeritageViewController: UIViewController {
    private let heritage: GimhaeHeritage
    
    private let scrollView = UIScrollView()
    private let wrapperStackView = UIStackView()
    private let stackView = VStackView()
    
    private let imageView = UIImageView()
    
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let assetNumberLabel = UILabel()
    private let contentLabel = UILabel()
    
    init(heritage: GimhaeHeritage) {
        self.heritage = heritage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        configure(heritage: heritage)
    }
    
    private func initView() {
        view.backgroundColor = .secondarySystemBackground
        view.add(scrollView) {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        scrollView.add(wrapperStackView) {
            $0.axis = .vertical
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
            }
        }
        wrapperStackView.addArranged(imageView, spacing: 8) {
            $0.contentMode = .scaleAspectFit
        }
        wrapperStackView.addArranged(HStackView([HSpace(16), stackView, HSpace(16)]))
        
        stackView.addArranged(nameLabel, spacing: 24) {
            $0.font = .preferredFont(forTextStyle: .largeTitle)
            $0.numberOfLines = 0
        }
        
        stackView.addArranged(addressLabel, spacing: 16) {
            $0.font = .preferredFont(forTextStyle: .caption1)
            $0.numberOfLines = 0
        }
        
        stackView.addArranged(assetNumberLabel, spacing: 32) {
            $0.font = .preferredFont(forTextStyle: .title3)
            $0.numberOfLines = 0
        }
        stackView.addArranged(contentLabel) {
            $0.font = .preferredFont(forTextStyle: .body)
            $0.numberOfLines = 0
        }

    }
    
    func configure(heritage: GimhaeHeritage) {
        if let imagePath = heritage.images.first, let url = URL(string: imagePath) {
            Task {
                if let image = try? await ImageDownloader.shared.image(from: url) {
                    self.imageView.image = image
                }
            }
        }
    
        nameLabel.text = heritage.name
        addressLabel.text = heritage.address
        assetNumberLabel.text = heritage.assetnumber
        contentLabel.text  = heritage.content
        contentLabel.numberOfLines = 0
        
    }
}

