//
//  ViewController.swift
//  UAS_C14190016
//
//  Created by IOS on 15/06/22.
//

import UIKit

struct CoinData {
    var symbol: String
    var name: String
    var image: String
    var usd: Double
    var idr: Double
}

class ViewController: UIViewController {
    
    @IBOutlet weak var coinTableView: UITableView!
    
    var _arrCoin = [CoinData]()
    
    var _haveCurrency = "USD"
    var _wantCurrency = "IDR"
    
    var _currencyExchange: Double!
    
    var _isAllServiceDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        coinTableView.delegate = self
        coinTableView.dataSource = self
        
        //start at currency exchange service
        self.currencyExchangeService()
        
    }
    
    func currencyExchangeService() {
        let headers = [
            "X-RapidAPI-Key": "8fa6404627msh510074de6eabf56p145b4djsne1ab946f8ccb",
            "X-RapidAPI-Host": "currency-exchange.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://currency-exchange.p.rapidapi.com/exchange?from=\(_haveCurrency)&to=\(_wantCurrency)&q=1.0")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            
            if let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Double {
                
                //print(json)
                
                self._currencyExchange = json
                
                DispatchQueue.main.async {
                    //continue to coinGecko service
                    self.coinGeckoService()
                }
            }
        })

        dataTask.resume()
    }
    
    func coinGeckoService() {
        let headers = [
            "X-RapidAPI-Key": "8fa6404627msh510074de6eabf56p145b4djsne1ab946f8ccb",
            "X-RapidAPI-Host": "coingecko.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://coingecko.p.rapidapi.com/coins/markets?vs_currency=usd&page=1&per_page=100&order=market_cap_desc")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
            
            if let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [Any] {
                
                //print(json)
                
                for item in json {
                    if let object = item as? [String: Any] {
                        let symbol = object["symbol"] as? String ?? ""
                        let name = object["name"] as? String ?? ""
                        let image = object["image"] as? String ?? ""
                        let usd = object["current_price"] as? Double ?? 0.0
                        
                        //3 digit
                        let x = usd * self._currencyExchange
                        let idr = Double(round(1000 * x) / 1000)
                        
                        let coin: CoinData = CoinData(
                            symbol: symbol,
                            name: name,
                            image: image,
                            usd: usd,
                            idr: idr
                        )
                        //print(coin)
                        
                        self._arrCoin.append(coin)
                    }
                }
                //print(self._arrCoin)
                
                DispatchQueue.main.async {
                    self._isAllServiceDone = true
                    
                    //reload new data
                    self.coinTableView.reloadData()
                }
                
            }
        })

        dataTask.resume()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //tingi cell
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !_isAllServiceDone {
            return 0
        }
        
        return _arrCoin.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = coinTableView.dequeueReusableCell(withIdentifier: "coinCell") as! CoinTableViewCell
        
        let coin = _arrCoin[indexPath.row]
        
        cell.nameLabel.text = coin.name
        cell.symbolLabel.text = coin.symbol.uppercased()
        cell.coinImageView.downloadImageFrom(url: coin.image)
        cell.usdLabel.text = "$ \(coin.usd)"
        cell.idrLabel.text = "Rp \(coin.idr)"
        
        let x = self._currencyExchange
        let exchange = Double(round(1000 * x!) / 1000)
        
        cell.exchangeLabel.text = "1 USD = \(exchange) IDR"
        
        //radius
        cell.coinView.layer.cornerRadius = cell.coinView.frame.height / 4
        
        return cell
    }
    
}

extension UIImageView {
    
    func downloadImageFrom(url: String) {
        let _url = URL(string: url)
        
        DispatchQueue.main.async { [weak self] in
            if let data = try? Data(contentsOf: _url!) {
                if let downloaded = UIImage(data: data) {
                    self?.image = downloaded
                }
            }
        }
    }
}
