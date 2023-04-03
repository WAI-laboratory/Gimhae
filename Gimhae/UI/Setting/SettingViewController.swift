import Foundation
import UIKit
import MessageUI
import SafariServices

class SettingViewController: UIViewController {
    
    private var core = SettingCore()
    private var tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        tableView.reloadData()
    }
    
    private func initView() {
        self.title = "나의 김해"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.add(tableView) {
            $0.delegate = self
            $0.dataSource = self
            $0.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.id)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}


extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = SettingSection.allCases[section]
        let models = self.core.state.models.filter({ $0.section == section })
        return models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("❤️ ")
        let section = SettingSection.allCases[indexPath.section]
        let models = self.core.state.models.filter({ $0.section == section})
        let model = models[indexPath.row]
        print("❤️ \(model)")
        
        switch model.item {
        case .version:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.id) as? SettingTableViewCell else { return UITableViewCell() }
            cell.accessoryView = nil
            cell.titleLabel.text = "🔖 버전 \(VersionService.shared.appStoreVersion ?? "")"
            return cell
        case .sendMail:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.id) as? SettingTableViewCell else { return UITableViewCell() }
            cell.accessoryView = nil
            cell.titleLabel.text = "👋 이런 기능 추가해주세요!"
            return cell

        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.id) as? SettingTableViewCell else { return UITableViewCell() }
            cell.accessoryView = nil
//            cell.titleLabel.text = model.item.title
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = SettingSection.allCases[indexPath.section]
        let models = self.core.state.models.filter({ $0.section == section})
        
        let model = models[indexPath.row]
        
        switch model.item {
        default: return 48
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingSection.allCases[indexPath.section]
        let models = self.core.state.models.filter({ $0.section == section})
        let model = models[indexPath.row].item
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch model {
            
        case .sendMail:
            let body = """
            \(UIDevice.current.model) \(UIDevice.current.systemVersion)
            """
            
            let subject = "이 앱에 대해 더 추천 하고 싶은 거 있나요?"
            if MFMailComposeViewController.canSendMail() {
                
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = self
                vc.setToRecipients(["aringod7@gmail.com"])
                vc.setSubject(subject)
                vc.setMessageBody(body, isHTML: false)
                present(vc, animated: true)
            } else {
                var url = "mailto:aringod7@gmail.com?subject=\(subject)&body=\(body)"
                url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }

        default:
            break
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }
}


extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let parent = controller.presentingViewController
        parent?.dismiss(animated: true)
    }
    
}


class SettingTableViewCell: UITableViewCell {
    static let id = "SettingTableViewCell"
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initView() {
        contentView.add(titleLabel) {
            $0.textAlignment = .left
            
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(12)
            }
        }
        
    }
}


import Foundation
import UIKit

class VersionService {
    static let shared = VersionService()
    var appStoreVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var buildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    func compare(lhs: String, rhs: String) -> ComparisonResult {
        let characterSet = CharacterSet(charactersIn: "0123456789.")
        let version1 = lhs.trimmingCharacters(in: characterSet.inverted).split(separator: ".").map { Int($0) ?? 0 }
        let version2 = rhs.trimmingCharacters(in: characterSet.inverted).split(separator: ".").map { Int($0) ?? 0 }
        let maxCount = max(version1.count, version2.count)
        for i in 0..<maxCount {
            let value1 = i >= version1.count ? 0 : version1[i]
            let value2 = i >= version2.count ? 0 : version2[i]
            if value1 > value2 {
                return .orderedDescending
            } else if value2 > value1 {
                return .orderedAscending
            }
        }
        return .orderedSame
    }
}
