import Foundation
import UIKit
import SnapKit

class VSpace: UIView {
    init(_ space: CGFloat) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.height.equalTo(space)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HSpace: UIView {
    init(_ space: CGFloat) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.width.equalTo(space)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VStackView: UIStackView {
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(_ views: [UIView]) {
        self.init()
        views.forEach({
            self.addArrangedSubview($0)
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews(_ views: [UIView]) {
        views.forEach { view in
            self.addArrangedSubview(view)
        }
    }
}


class HStackView: UIStackView {
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    convenience init(_ views: [UIView]) {
        self.init()
        views.forEach({
            self.addArrangedSubview($0)
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .horizontal
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func equalCenter() -> HStackView {
        self.distribution = .equalCentering
        return self
    }
    
    func fillEqually() -> HStackView {
        self.distribution = .fillEqually
        return self
    }
}


class WrapperView: UIView {
    private var wrappedView: UIView
    private var topConstraint: ConstraintMakerEditable? = nil
    private var leadingConstraint: ConstraintMakerEditable? = nil
    private var bottomConstraint: ConstraintMakerEditable? = nil
    private var trailingConstraint: ConstraintMakerEditable? = nil
    private var centerXConstraint: ConstraintMakerEditable? = nil
    private var centerYConstraint: ConstraintMakerEditable? = nil
    private var centerConstraint: ConstraintMakerEditable? = nil
    

    init(
        top: CGFloat? = nil,
        leading: CGFloat? = nil,
        bottom: CGFloat? = nil,
        trailing: CGFloat? = nil,
        centerX: Bool = false,
        centerY: Bool = false,
        center: Bool = false,
        _ view: UIView
    ) {
        self.wrappedView = view
        super.init(frame: .zero)
        self.add(view) {
            $0.snp.makeConstraints { [unowned self]make in
                if let top = top {
                    self.topConstraint = make.top.equalTo(top)
                }
                if let leading = leading {
                    self.leadingConstraint = make.leading.equalTo(leading)
                }
                if let bottom = bottom {
                    self.bottomConstraint = make.bottom.equalTo(bottom)
                }
                if let trailing = trailing {
                    self.trailingConstraint = make.trailing.equalTo(trailing)
                }
                if centerX {
                    self.centerXConstraint = make.centerX.equalToSuperview()
                }
                if centerY {
                    self.centerYConstraint = make.centerY.equalToSuperview()
                }
                if center {
                    self.centerConstraint = make.center.equalToSuperview()
                }
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        return nil
    }
    
    func leading(_ leading: CGFloat = 0) -> WrapperView {
        
        if let _ = leadingConstraint {
            self.wrappedView.snp.updateConstraints { [unowned self] make in
                self.leadingConstraint = make.leading.equalTo(leading)
            }
        } else {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.leadingConstraint = make.leading.equalTo(leading)
            }
        }
        return self
    }
    
    func top(_ top: CGFloat = 0) -> WrapperView {
        
        if let _ = topConstraint {
            self.wrappedView.snp.updateConstraints { [unowned self] make in
                self.topConstraint = make.top.equalTo(top)
            }
        } else {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.topConstraint = make.top.equalTo(top)
            }
        }
        return self
    }
    func bottom(_ bottom: CGFloat = 0) -> WrapperView {
        
        if let _ = bottomConstraint {
            self.wrappedView.snp.updateConstraints { [unowned self] make in
                self.bottomConstraint = make.bottom.equalTo(bottom)
            }
        } else {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.bottomConstraint = make.bottom.equalTo(bottom)
            }
        }
        return self
    }
    func trailing(_ trailing: CGFloat = 0) -> WrapperView {
        
        if let _ = trailingConstraint {
            self.wrappedView.snp.updateConstraints { [unowned self] make in
                self.trailingConstraint = make.trailing.equalTo(trailing)
            }
        } else {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.trailingConstraint = make.trailing.equalTo(trailing)
            }
        }
        return self
    }
    
    func centerX(_ centerX: Bool = true) -> WrapperView {
        
        if centerX {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.centerXConstraint = make.centerX.equalToSuperview()
            }
        }
        return self
    }
    
    func centerY(_ centerY: Bool = true) -> WrapperView {
        
        if centerY {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.centerYConstraint = make.centerY.equalToSuperview()
            }
        }
        return self
    }
    
    func center(_ center: Bool = true) -> WrapperView {
        
        if center {
            self.wrappedView.snp.makeConstraints { [unowned self] make in
                self.centerConstraint = make.center.equalToSuperview()
            }
        }
        return self
    }
}
