//
//  PrivyDoc.swift
//  PrivyDocEmbedded
//
//  Created by Marsudi Widodo on 27/06/19.
//  Copyright © 2019 PrivyID. All rights reserved.
//


import UIKit
import WebKit

public protocol PrivyDocDelegate {
	func afterAction()
	func afterSign()
	func afterReview()
}

public class PrivyDoc: UIViewController {
	
	var webView: WKWebView!
	var documentToken = ""
	var delegate: PrivyDocDelegate!
	
	let activityIndicatorView = UIActivityIndicatorView(style: .gray)
	
	init(){
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init (coder:) has not been implemented")
	}
	
	override public func viewDidLoad() {
		super.viewDidLoad()
		print("Initializing...")
		view.backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 1)
		initializeWebView()
		loadWebView()
	}
	
	func convertToDictionary(text: String) -> [String: Any]? {
		if let data = text.data(using: .utf8) {
			do {
				return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
			} catch {
				print(error.localizedDescription)
			}
		}
		return nil
	}
	
	private func initializeWebView() {
		let configuration = WKWebViewConfiguration()
		configuration.userContentController.add(self, name: "action")
		webView = WKWebView(frame: view.frame, configuration: configuration)
		webView.backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 1)
		webView.translatesAutoresizingMaskIntoConstraints = false
		webView.navigationDelegate = self
		webView.scrollView.delegate = self
		webView.scrollView.bounces = false
		webView.scrollView.showsVerticalScrollIndicator = false
		webView.scrollView.showsHorizontalScrollIndicator = false
		view = webView
	}
	
	private func loadWebView(){
		webView.loadHTMLString("""
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/><meta http-equiv="X-UA-Compatible" content="ie=edge"><title>Document</title></head><body><div class="privy-document"></div><script src="https://unpkg.com/privy-sdk@next"></script><script type="text/javascript">function openDoc(token){Privy.openDoc(token,{dev: false, signature:{page: 11, x: 130, y: 468, fixed: false,}}).on('after-action', (data)=>{window.webkit.messageHandlers['action'].postMessage('after-action');}).on('after-sign', (data)=>{window.webkit.messageHandlers['action'].postMessage('after-sign');}).on('after-review', (data)=>{window.webkit.messageHandlers['action'].postMessage('after-review');})}</script></body></html>
""", baseURL: nil)
	}
	
	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}

extension PrivyDoc: WKScriptMessageHandler {
	public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		let action = message.body as! String
		if action == "after-action"{
			delegate.afterAction()
		} else if action == "after-sign"{
			delegate.afterSign()
		} else{
			delegate.afterReview()
		}
	}
}

extension PrivyDoc: UIScrollViewDelegate {
	private func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
		scrollView.pinchGestureRecognizer?.isEnabled = false
	}
}


extension PrivyDoc: WKNavigationDelegate{
	
	private func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		print("Loaded...")
		activityIndicatorView.stopAnimating()
		webView.evaluateJavaScript("openDoc('\(documentToken)')") { result, error in
			guard error == nil else {
				return
			}
		}
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return nil
	}
	
	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		decisionHandler(.allow)
	}
	
	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		print(error.localizedDescription)
	}
}

public class PrivyDocEmbedded: UINavigationController{
	
	public var docDelegate: PrivyDocDelegate!
	
	public required init(documentToken: String){
		let vc = PrivyDoc()
		vc.documentToken = documentToken
		vc.delegate = docDelegate
		super.init(rootViewController: vc)
		prepareNavigation()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init (coder:) has not been implemented")
	}
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
	}
	
	func prepareNavigation(){
		navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
		navigationBar.layer.masksToBounds = false
		navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
		navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
		navigationBar.layer.shadowRadius = 0.8
		navigationBar.layer.shadowOpacity = 0.3
		navigationBar.isTranslucent = false
		view.backgroundColor = .white
		navigationBar.barStyle = .default
		navigationBar.tintColor = #colorLiteral(red: 0.8823529412, green: 0.1921568627, blue: 0.2, alpha: 1)
		navigationBar.barTintColor = .white
	}
}

