//
//  ResultsViewController.swift
//  ProductVision
//
//  Created by David Hodge on 2/1/17.
//  Copyright © 2017 Genesis Apps. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SafariServices

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var products: Array<Product>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Similar Products"
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let productCount = products?.count
        {
            return productCount
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
        
        if let products = products
        {
            let product = products[indexPath.row]
            
            // Set Image
            if let imageUrl = product.imageUrl
            {
                cell.productImageView.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, imageUrl) -> Void in
                    
                    if image != nil && cacheType != .memory
                    {
                        cell.productImageView.alpha = 0.0
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            cell.productImageView.alpha = 1.0
                        })
                    }
                })
            }
            
            // Set Product Title
            if let productTitle = product.productTitle
            {
                cell.titleLabel.text = productTitle
            }
            
            // Set Product Price
            if let productPrice = product.productPrice
            {
                cell.priceLabel.text = productPrice
            }
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let products = products
        {
            let product = products[indexPath.row]
            
            if let urlString = product.outboundUrlString
            {
                if let outboundUrl = URL(string: urlString)
                {
                    let safariVc = SFSafariViewController(url: outboundUrl)
                    
                    present(safariVc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
}
