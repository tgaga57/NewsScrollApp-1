//
//  NewsViewController.swift
//  NewsScrollApp
//
//  Created by 原田悠嗣 on 2019/08/11.
//  Copyright © 2019 原田悠嗣. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit
import NVActivityIndicatorView

class NewsViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate, WKNavigationDelegate, XMLParserDelegate{
    
    // 引っ張って更新
    var refreshControl: UIRefreshControl!
    
    // インジゲーターの変数
    var activityIndicatorView: NVActivityIndicatorView!
    
    // テーブルビューのインスタンスを取得
    var tableView: UITableView = UITableView()
    // ロード時画面のview
    var indicatorBackgroundView: UIView!
    
    // XMLParserのインスタンスを取得
    var parser = XMLParser()
    
    // 記事情報の配列の入れ物
    var articles: [Any] = []
    // XMLファイルに解析をかけた情報
    var elements = NSMutableDictionary()
    // XMLファイルのタグ情報
    var elememt: String = ""
    // XMLファイルのタイトル情報
    var titleString: String = ""
    // XMLファイルのリンク情報
    var linkString: String = ""
    
    // webview
    @IBOutlet weak var webView: WKWebView!
    
    // toolbar(4つのボタンがはいってる)
    @IBOutlet weak var toolBar: UIToolbar!
    
    // urlを受け取る
    var url: String = ""
    // itemInfoを受け取る
    var itemInfo: IndicatorInfo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // refreshControlのインスタンス
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // デリゲートとの接続
        tableView.delegate = self
        tableView.dataSource = self
        
        // navigationDelegateとの接続
        webView.navigationDelegate = self
        
        // tableviewのサイズを確定
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        // tableviewをviewに追加
        self.view.addSubview(tableView)
        
        // refreshControlをテーブルビューにつける
        tableView.addSubview(refreshControl)
        
        // 最初は隠す（tableviewが表示されるのを邪魔しないように）
        webView.isHidden = true
        toolBar.isHidden = true
        // インジゲーターのサイズ
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 100, width: 60, height: 60))
        // インジゲーターをセンターへ
         activityIndicatorView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 50)
        parseUrl()
    }
    
    // インディゲーターを表示
    func showLoadIndicator() {
        // インジケータが表示された時の背景
        indicatorBackgroundView = UIView(frame: self.view.bounds)
        indicatorBackgroundView?.backgroundColor = UIColor.black
        indicatorBackgroundView?.alpha = 0.4
        indicatorBackgroundView?.tag = 1
        
        // インジケータと背景を接続
        self.view.addSubview(indicatorBackgroundView)
        indicatorBackgroundView?.addSubview(activityIndicatorView)
        //
        //        //起動
        activityIndicatorView.startAnimating()
    }
    
    // インジケータを非表示にする
    func stopLoadIndicator() {
        // インジケータを消すか判断
        if let viewWithTag = self.view.viewWithTag(1) {
            viewWithTag.removeFromSuperview()
        }
        // 消えます
        activityIndicatorView.stopAnimating()
    }
    
    @objc func refresh() {
        // 2秒後にdelayを呼ぶ
        perform(#selector(delay), with: nil, afterDelay: 2.0)
    }
    
    @objc func delay() {
        parseUrl()
        // refreshControlを終了
        refreshControl.endRefreshing()
    }
    
    // urlを解析する
    func parseUrl() {
        // url型に変換
        let urlToSend: URL = URL(string: url)!
        // parser に解析対象のurlを格納
        parser = XMLParser(contentsOf: urlToSend)!
        // 記事情報を初期化
        articles = []
        // parserとの接続
        parser.delegate = self
        // 解析の実行
        parser.parse()
        // TableViewのリロード
        tableView.reloadData()
    }
    // 解析中に要素の開始タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // elememtNameにタグの名前が入ってくるのでelementに代入
        elememt = elementName
        // エレメントにタイトルが入ってきたら
        if elememt == "item" {
            // 初期化
            elements = [:]
            titleString = ""
            linkString = ""
        }
    }
    
    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if elememt == "title" {
            titleString.append(string)
        } else if elememt == "link" {
            linkString.append(string)
        }
    }
    
    // 終了タグを見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // アイテムという要素の中にあるなら、
        if elementName == "item" {
            // titleStringの中身が空でないなら
            if titleString != "" {
                // elementsに"title"というキー値を付与しながらtitleStringをセット
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            // linkStringの中身が空でないなら
            if linkString != "" {
                // elementsに"link"というキー値を付与しながらlinkStringをセット
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            // articlesの中にelementsを入れる
            articles.append(elements)
        }
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 記事の数だけセルを返す
        return articles.count
    }
    // セルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        // セルの色
        cell.backgroundColor = #colorLiteral(red: 0.8635054231, green: 1, blue: 0.8127393723, alpha: 1)
        
        // 記事テキストサイズとフォント
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.textLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "title") as? String
        cell.textLabel?.textColor = UIColor.black
        
        // 記事urlのサイズとフォント
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.detailTextLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "link") as? String
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    // セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        let linkUrl = ((articles[indexPath.row] as AnyObject).value(forKey: "link") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlStr = (linkUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        guard let url = URL(string: urlStr) else {
            return
        }
        let urlRequest = NSURLRequest(url: url)
        // ここでロード
        webView.load(urlRequest as URLRequest)
        // セルをタップした時にインジケータを表示
        showLoadIndicator()
        // セルを押した後、他のセルを押せなくする
        self.tableView.allowsSelection = false
    }
    // ページの読み込み完了時に呼ばれる
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //tableviewを隠す
        tableView.isHidden = true
        // toolbarを表示する
        toolBar.isHidden = false
        // webviewを表示する
        webView.isHidden = false
        
        // インジケータを非表示にする
        stopLoadIndicator()
        // セルを再び押せるようにする
        self.tableView.allowsSelection = true
    }
    // キャンセル
    @IBAction func cancel(_ sender: Any) {
        tableView.isHidden = false
        toolBar.isHidden = true
        webView.isHidden = true
    }
    // 戻る
    @IBAction func backPage(_ sender: Any) {
        webView.goBack()
    }
    // 次へ
    @IBAction func nextPage(_ sender: Any) {
        webView.goForward()
    }
    // リロード
    @IBAction func refreshPage(_ sender: Any) {
        webView.reload()
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}
