
import Foundation
import UIKit
import AddThen
import SnapKit

//class DataViewController: BaseViewController {
//    let url = "https://stat.gimhae.go.kr/home/content.do?menu=10"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//}

import WebKit

class DataViewController: UIViewController,WKUIDelegate,WKNavigationDelegate{

    
    var webView: WKWebView = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.add(webView) {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let url = URL(string: "https://stat.gimhae.go.kr/home/content.do?menu=67")
        let request = URLRequest(url: url!)
        //self.webView?.allowsBackForwardNavigationGestures = true  //뒤로가기 제스쳐 허용
        webView.configuration.preferences.javaScriptEnabled = true  //자바스크립트 활성화
        webView.load(request)

    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() } //모달창 닫힐때 앱 종료현상 방지.
    
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void){
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler() }))
        self.present(alertController, animated: true, completion: nil) }

    //confirm 처리
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in completionHandler(false) }))
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in completionHandler(true) }))
        self.present(alertController, animated: true, completion: nil) }
    
    // href="_blank" 처리
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
        return nil }
    
}
