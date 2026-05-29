//
//  PlaceListCell.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import SnapKit
import Kingfisher

final class PlaceListCell: UITableViewCell {
    static let identifier = "PlaceListCell"
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private let categoryBadge = UILabel()
    private let addressLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Thumbnail
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.backgroundColor = .tertiarySystemBackground
        
        // Title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        
        // Summary
        summaryLabel.font = .systemFont(ofSize: 13, weight: .regular)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 2
        
        // Category badge
        categoryBadge.font = .systemFont(ofSize: 11, weight: .medium)
        categoryBadge.textColor = .white
        categoryBadge.textAlignment = .center
        categoryBadge.layer.cornerRadius = 4
        categoryBadge.clipsToBounds = true
        
        // Address
        addressLabel.font = .systemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = .tertiaryLabel
        addressLabel.numberOfLines = 1
        
        // Layout
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(summaryLabel)
        contentView.addSubview(categoryBadge)
        contentView.addSubview(addressLabel)
        
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 72))
        }
        
        categoryBadge.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(18)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(categoryBadge.snp.bottom).offset(4)
        }
        
        summaryLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(summaryLabel.snp.bottom).offset(4)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    func configure(with place: any Place) {
        titleLabel.text = place.placeName
        summaryLabel.text = place.placeSummary
        addressLabel.text = place.placeAddress
        
        // Category badge
        categoryBadge.text = "  \(place.placeCategory.title)  "
        categoryBadge.backgroundColor = colorForCategory(place.placeCategory)
        
        // Thumbnail
        if let urlString = place.placeThumbnailURL, let url = URL(string: urlString) {
            thumbnailImageView.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: place.placeCategory.iconName)?.withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
            )
        } else {
            thumbnailImageView.image = UIImage(systemName: place.placeCategory.iconName)?
                .withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal)
        }
    }
    
    private func colorForCategory(_ category: PlaceCategory) -> UIColor {
        switch category {
        case .attraction: return .systemBlue
        case .restaurant: return .systemOrange
        case .heritage: return .systemBrown
        case .festival: return .systemPurple
        case .accommodation: return .systemTeal
        case .parking: return .systemGray
        case .wifi: return .systemGreen
        case .bicycle: return .systemYellow
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.kf.cancelDownloadTask()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        summaryLabel.text = nil
        addressLabel.text = nil
        categoryBadge.text = nil
    }
}
