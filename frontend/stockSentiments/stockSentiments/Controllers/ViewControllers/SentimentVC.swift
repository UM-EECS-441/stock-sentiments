//
//  SentimentVC.swift
//  stockSentiments
//
//  Created by Ibtida I. Bhuiyan on 10/23/20.
//

import UIKit
import Charts
import TinyConstraints

let sentimentStoryboard: UIStoryboard = UIStoryboard(name: "Sentiment", bundle: nil)


class ChartXAxisFormatter: NSObject {
    var dateFormatter: DateFormatter?
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if let dateFormatter = dateFormatter {
            
            let date = Date(timeIntervalSince1970: value)
            return dateFormatter.string(from: date)
        }
        
        return ""
    }
    
}


class SentimentVC: UIViewController, ChartViewDelegate {
    
    var ticker: Ticker? = nil
    var selectSort: String? = ""
    var tickerSymbol: String? = nil
    
    var sentimentResults: [Data]? = nil
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBackground
        chartView.drawGridBackgroundEnabled = false
        chartView.legend.verticalAlignment = .top
        chartView.legend.horizontalAlignment = .center
        
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .systemBlue
        yAxis.labelPosition = .insideChart
        yAxis.drawGridLinesEnabled = false
        
        let xAxis = chartView.xAxis
        
        let xValuesNumberFormatter = ChartXAxisFormatter()
        xValuesNumberFormatter.dateFormatter = DateFormatter()
        xValuesNumberFormatter.dateFormatter?.dateFormat = "h a"
        xAxis.valueFormatter = xValuesNumberFormatter
        
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.setLabelCount(5, force: true)
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.labelTextColor = .label
        xAxis.drawGridLinesEnabled = false
        
        return chartView
    }()
    
    var isChartRendered = false
    var sentimentScoreValues: [ChartDataEntry]? = []
    var stockPriceValues: [ChartDataEntry]? = []
    var overlayLabel: UILabel? = nil
    var overlaySwitch: UISwitch? = nil
    
    var pVC: UITableViewController? = nil // pointer to parent view controller needed to replace view
    
    @IBOutlet weak var sentimentTitle: UILabel!
    @IBOutlet weak var sentimentScore: UILabel!
    @IBOutlet weak var sentimentDescription: UITextView!
    @IBOutlet weak var sentimentUnsubscribe: UIButton!
    
    // Create unsubscribe alert and bind actions to click options
    @IBAction func unsubscribeTapped(_ sender: Any) {
        
        guard let ticker = self.ticker else {
            fatalError("SentimentVC doesn't have Ticker in scope")
        }
        
        let unsubscribeAlert = UIAlertController(title: "Unsubscribe", message: "Are You Sure you want to unsubscribe from " + ticker.symbol + "?", preferredStyle: UIAlertController.Style.alert)
        
        unsubscribeAlert.addAction(UIAlertAction(title: "Unsubscribe", style: .default, handler: { (action) -> Void in
            requestUnSubscribe(to: ticker.symbol) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: { [self] in
                            let subscribeVC =  subscribeStoryboard.instantiateViewController(withIdentifier: "SubscribeVC") as! SubscribeVC
                            
                            sharedUser.requestAndUpdateUserWatchlist(autoReset: true, sortType: selectSort!, completion: {
                                
                                subscribeVC.tickerSymbol = ticker.symbol
                                subscribeVC.tickerName = ticker.name
                                // set destination's parent to self's parent and present modally from parent
                                guard let pVC = self.pVC else {
                                    fatalError("Parent view controller not set")
                                }
                                subscribeVC.pVC = pVC
                                DispatchQueue.main.async {
                                    self.pVC?.present(subscribeVC, animated: true, completion: self.refreshWatchlistTableViewIfIsParent)
                                }
                            })
                        })
                    }
                } else {
                    print("already subbed")
                }
            }
        }))
        
        unsubscribeAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            unsubscribeAlert.dismiss(animated: true, completion: nil)
        }))
        
        present(unsubscribeAlert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let ticker = self.ticker else {
            fatalError("SentimentVC doesn't have Ticker in scope")
        }
        
        // set color
        let sentimentLabel: SentimentLabel = getSentimentLabel(score: ticker.sentimentScore)
        self.setColor(primary: sentimentLabel.color)
        
        // set text
        sentimentTitle.text = ticker.name + " (" + ticker.symbol + ")"
        sentimentScore.text = String(ticker.sentimentScore)
        sentimentDescription.text = "People are saying " + sentimentLabel.rawValue + " things about " + ticker.name
        
        // setting up chart
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20.0).isActive = true
        lineChartView.topAnchor.constraint(equalTo: self.sentimentDescription.bottomAnchor, constant: 10.0).isActive = true

        // adding overlay switch elements
        self.overlayLabel = UILabel.init()
        view.addSubview(self.overlayLabel!)
        self.overlayLabel!.text = "Show stock price"
        self.overlayLabel!.frame.size = self.overlayLabel!.intrinsicContentSize
        self.overlayLabel!.textAlignment = .left
        self.overlayLabel!.centerXToSuperview()
        self.overlayLabel!.centerYAnchor.constraint(equalTo: self.lineChartView.bottomAnchor, constant: 25.0).isActive = true
        self.overlayLabel!.isHidden = true
        
        self.overlaySwitch = UISwitch.init()
        view.addSubview(self.overlaySwitch!)
        self.overlaySwitch!.isOn = false
        self.overlaySwitch!.centerY(to: self.overlayLabel!)
        self.overlaySwitch!.leadingToTrailing(of: overlayLabel!, offset: 10.0, isActive: true)
        self.overlaySwitch!.isHidden = true
        self.overlaySwitch!.addTarget(self, action: #selector(updateChart), for: .valueChanged)
        
        // getting data for chart
        requestSentiment(to: ticker.symbol, completionHandler: {
            (sentiments) -> Void in
            self.sentimentResults = sentiments
            
            var j: Double = 0.0
            for i in stride(from: 0, through: self.sentimentResults!.count - 1, by: 4) {
                let sentiment = self.sentimentResults![i]
                
                // calculating date for x value
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                let timeValue = dateFormatter.date(from: String(sentiment.time.dropLast(4)))?.timeIntervalSince1970
                
                self.sentimentScoreValues?.append(ChartDataEntry(x: timeValue!, y: sentiment.sentiment))
                self.stockPriceValues?.append(ChartDataEntry(x: timeValue!, y: sentiment.price))
                j += 1
            }
            self.sentimentScoreValues?.reverse()
            self.stockPriceValues?.reverse()
            if (self.sentimentScoreValues!.count > 0) {
                DispatchQueue.main.async {
                    self.overlayLabel!.isHidden = false
                    self.overlaySwitch!.isHidden = false
                    self.updateChart(switchState: self.overlaySwitch!)
                }
            }
        })
    }

    @objc func updateChart(switchState: UISwitch) {
        if switchState.isOn {
            setChartDataWithOverlay()
        } else {
            setChartDataWithoutOverlay()
        }
    }
    
    func setChartDataWithoutOverlay() {
        let set = LineChartDataSet(entries: self.sentimentScoreValues, label: "Sentiment Score")
        set.drawCirclesEnabled = false
        set.mode = .cubicBezier
        set.setColor(.systemBlue, alpha: 0.75)
        set.axisDependency = .left
//        let gradientColors = [UIColor.systemBlue.cgColor, UIColor.cyan.cgColor] as CFArray // Colors of the gradient
//        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
//        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
//        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
//        set.drawFilledEnabled = true // Draw the Gradient
        
        let data = LineChartData(dataSet: set)
        data.setDrawValues(false)
        lineChartView.data = data
        
        // disabling right y-axis to hide stock data
        lineChartView.rightAxis.enabled = false
        if (!isChartRendered) {
            lineChartView.animate(xAxisDuration: 1.2)
            isChartRendered = true
        }
    }
    
    func setChartDataWithOverlay() {
        // sentiment score dataset
        let set1 = LineChartDataSet(entries: self.sentimentScoreValues, label: "Sentiment Score")
        set1.drawCirclesEnabled = false
        set1.mode = .cubicBezier
        set1.setColor(.systemBlue, alpha: 0.75)
        set1.axisDependency = .left
        
        // stock price dataset
        let set2 = LineChartDataSet(entries: self.stockPriceValues, label: "Stock Price")
        set2.drawCirclesEnabled = false
        set2.mode = .cubicBezier
        set2.setColor(.systemGreen, alpha: 0.75)
        set2.axisDependency = .right
        
        var lineChartDataSets: [LineChartDataSet] = []
        lineChartDataSets.append(set1)
        lineChartDataSets.append(set2)
        
        let data = LineChartData(dataSets: lineChartDataSets)
        data.setDrawValues(false)
        lineChartView.data = data
        
        let yAxis = lineChartView.rightAxis
        yAxis.enabled = true
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .systemGreen
        yAxis.labelPosition = .insideChart
        yAxis.drawGridLinesEnabled = false
        if (!isChartRendered) {
            lineChartView.animate(xAxisDuration: 1.2)
            isChartRendered = true
        }
    }
    
    // reloads table view data using the pVC pointer
    func refreshWatchlistTableViewIfIsParent() {
        if let pVC = self.pVC as? WatchlistVC {
            DispatchQueue.main.async {
                pVC.tableView.reloadData()
            }
        }
    }
    
    func setColor(primary primaryColor: UIColor) {
        //        sentimentTitle.textColor = primaryColor
        sentimentScore.textColor = primaryColor
        //        sentimentDescription.textColor = primaryColor
        sentimentUnsubscribe.tintColor = .systemBlue
    }
}
