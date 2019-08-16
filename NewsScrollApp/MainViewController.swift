//
//  MainViewController.swift
//  NewsScrollApp
//
//  Created by 原田悠嗣 on 2019/08/11.
//  Copyright © 2019 原田悠嗣. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainViewController: ButtonBarPagerTabStripViewController {
    // URLの文字列（yahoo,NHK,週刊文春)
    let urlList: [String] = ["https://news.yahoo.co.jp/pickup/domestic/rss.xml",
                             "https://www.nhk.or.jp/rss/news/cat0.xml",
                             "http://shukan.bunshun.jp/list/feed/rss"]
    // タブの名前の表示
    var iteminfo: [IndicatorInfo] = ["Yahoo!", "NHK", "週刊文春"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // 各VCを返す処理
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        // 返すViewControllerの配列
        var childViewControllers: [UIViewController] = []
        // 各ViewControllerにurlとiteminfoの情報を受け渡し
        for i in 0 ..< urlList.count {
            // viewcontrollerのインスタンス化
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "News") as! NewsViewController
            // 値の受け渡し
            VC.url = urlList[i]
            VC.itemInfo = iteminfo[i]
            // 配列にappend
            childViewControllers.append(VC)
        }
        // VCを返す
        return childViewControllers
    }
}

