//
//  OfflineBannerView.swift
//  Gimhae
//
//  Created by 이용준 on 2026/05/29.
//

import UIKit
import Combine
import SnapKit

final class OfflineBannerView: UIView {
    
    private let label = UILabel()
    private let iconView = UIImageView()
    private var subscription = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemOrange
        isHidden = true
        
        iconView.image = UIImage(systemName: "wifi.slash")
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        
        label.text = "common.offline".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        
        addSubview(iconView)
        addSubview(label)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(28)
        }
    }
    
    private func bind() {
        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                UIView.animate(withDuration: 0.3) {
                    self?.isHidden = isConnected
                    self?.alpha = isConnected ? 0 : 1
                }
            }
            .store(in: &subscription)
    }
}
