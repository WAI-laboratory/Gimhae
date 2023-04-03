import Foundation
import UIKit
import Combine
import CombineCocoa

class LargeSegmentView: UIView {
    
    let segmentedControl = UISegmentedControl()
    let segments: [LargeSegmentItem]
    private let bottomBar = UIView()
    
    
    init(_ segments: [LargeSegmentItem]) {
        self.segments = segments
        super.init(frame: .zero)
        for (index, segmentedItem) in segments.enumerated() {
            insertSegment(title: segmentedItem.title, at: index)
        }

        segmentedControl.backgroundColor = .clear
        segmentedControl.tintColor = .clear
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        let emptyImage = UIImage()
        segmentedControl.setBackgroundImage(emptyImage, for: .normal, barMetrics: .default)
        segmentedControl.setBackgroundImage(emptyImage, for: .selected, barMetrics: .default)
        segmentedControl.setBackgroundImage(emptyImage, for: .highlighted, barMetrics: .default)
        segmentedControl.setDividerImage(emptyImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor : UIColor.label
        ], for: .selected)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .body),
            NSAttributedString.Key.foregroundColor : UIColor.label
        ], for: .normal)
        initView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView() {
        self.add(segmentedControl) {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        self.add(bottomBar) {
            
            $0.backgroundColor = .label
            $0.snp.makeConstraints { make in
                make.height.equalTo(2)
                make.bottom.equalToSuperview()
                make.leading.equalTo(self.segmentedControl.snp.leading)
                make.width.equalTo(self.segmentedControl).multipliedBy((1 / CGFloat(self.segmentedControl.numberOfSegments)))
            }
        }
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    func insertSegment(title: String, at index: Int) {
        segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        UIView.animate(withDuration: 0.3) {
            let originX = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex)
            self.bottomBar.frame.origin.x = originX
        } completion: { [weak self] _ in
            guard let self else { return }
            
            let originX = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex)
            self.bottomBar.frame.origin.x = originX
        }
    }
}


struct LargeSegmentItem: Hashable {
    var title: String
    var image: UIImage?
}
//
//
//extension Reactive where Base: LargeSegmentView {
//    var selectedSegmentIndex: ControlProperty<Int> {
//        base.segmentedControl.rx.selectedSegmentIndex
//    }
//
//    var value: ControlProperty<Int> {
//        base.segmentedControl.rx.value
//    }
//}
