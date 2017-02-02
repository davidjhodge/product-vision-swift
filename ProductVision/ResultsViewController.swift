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
// Temp
import ObjectMapper

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var products: Array<Product>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Similar Products"
        
        // Dummy info
        if let product = Mapper<Product>().map(JSON: ["imageUrl": "https://images-na.ssl-images-amazon.com/images/I/51Rf7pJ8vrL._SX466_.jpg",
                                                   "productTitle": "Kit Kat Valentines Fun SIze Bars (32 Ounce)",
                                                   "productPrice": "$10.99"])
        {
            products = [product]
        }
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
    }
    
    
}
