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

struct CurrencyConverter: Decodable {
    var new_currency: String
    var old_currency: String
    var new_amount: Double
    var old_amount: Double
    
}

class ViewController: UIViewController {
    
    @IBOutlet weak var coinTableView: UITableView!
    
    var _arrCoin = [CoinData]()
    
    var _haveCurrency = "USD"
    var _wantCurrency = "IDR"
    
    var _currencyData: CurrencyConverter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        coinTableView.delegate = self
        coinTableView.dataSource = self
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        currencyConverterService()
        dispatchGroup.leave()
        sleep(2)
        dispatchGroup.enter()
        coinGeckoService()
        dispatchGroup.leave()
        sleep(2)
        
    }
    
    func currencyConverterService() {
        let headers = [
            "X-RapidAPI-Key": "8fa6404627msh510074de6eabf56p145b4djsne1ab946f8ccb",
            "X-RapidAPI-Host": "currency-converter-by-api-ninjas.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://currency-converter-by-api-ninjas.p.rapidapi.com/v1/convertcurrency?have=\(_haveCurrency)&want=\(_wantCurrency)&amount=1")! as URL,
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

            if let dataCurrency = data {
                let decoder = JSONDecoder()

                do {
                    let decodeData = try decoder.decode(CurrencyConverter.self, from: dataCurrency)
                    
                    print(type(of: decodeData.new_amount))
                    
                    let newCurrencyData = CurrencyConverter(
                        new_currency: decodeData.new_currency,
                        old_currency: decodeData.old_currency,
                        new_amount: decodeData.new_amount,
                        old_amount: decodeData.old_amount
                    )

                    self._currencyData = newCurrencyData
                    

                } catch {
                    print(error)
                }
            }
        })
        dataTask.resume()
    }
    
    func coinGeckoService() {
        let headers2 = [
            "X-RapidAPI-Key": "8fa6404627msh510074de6eabf56p145b4djsne1ab946f8ccb",
            "X-RapidAPI-Host": "coingecko.p.rapidapi.com"
        ]

        let request2 = NSMutableURLRequest(
            url: NSURL(string: "https://coingecko.p.rapidapi.com/coins/markets?vs_currency=usd&page=1&per_page=100&order=market_cap_desc")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0
        )
        
        request2.httpMethod = "GET"
        request2.allHTTPHeaderFields = headers2

        let session2 = URLSession.shared
        let dataTask2 = session2.dataTask(with: request2 as URLRequest, completionHandler: { (data, response, error) -> Void in
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
                        let x = usd * self._currencyData.new_amount
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
            }
        })

        dataTask2.resume()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        let x = self._currencyData.new_amount
        let exchange = Double(round(1000 * x) / 1000)
        
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
