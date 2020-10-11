//
//  CandlestickChartViewController.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import UIKit
import Charts

class CandlestickChartViewController: UIViewController, IAxisValueFormatter, ChartViewDelegate, IValueFormatter {
    // MARK: Private types
    private enum State: String {
        case aapl
        case msft
        case spy
    }

    // MARK: Private Properties
    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var chartView: CandleStickChartView!
    private var stocks = [Stock]()
    private weak var axisValueFormatter: IAxisValueFormatter?
    private weak var valueFormatter: IValueFormatter?

    private var state: State = .aapl {
        didSet {
            handleStateChange()
        }
    }

    // MARK: Public Methods
    func configure(with stocks: [Stock]) {
        self.stocks = stocks
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        detailsLabel.text = ""
        axisValueFormatter = self
        valueFormatter = self
        chartView.xAxis.valueFormatter = axisValueFormatter
        chartView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadChart()
    }

    // MARK: Private Methods
    private func handleStateChange() {
        reloadChart()
    }

    private func reloadChart() {
        let stockPrices = getPrices()
        let dataSet = CandleChartDataSet(label: state.rawValue.uppercased())
        for (index, stockPrice) in stockPrices.enumerated() {
            let entry = CandleChartDataEntry(x: Double(index), shadowH: stockPrice.high, shadowL: stockPrice.low, open: stockPrice.open, close: stockPrice.close)
            dataSet.append(entry)
        }

        dataSet.valueFormatter = valueFormatter
        dataSet.neutralColor = .black
        dataSet.increasingColor = .black
        dataSet.decreasingColor = .black
        dataSet.shadowColor = .black
        dataSet.shadowWidth = 1
        dataSet.barSpace = 0.3

        chartView.clear()
        detailsLabel.text = ""
        chartView.data = CandleChartData(dataSet: dataSet)
    }

    @IBAction private func handleSegmentedControlValueChanged(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl else { return }

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            state = .aapl
        case 1:
            state = .msft
        case 2:
            state = .spy
        default:
            state = .aapl
        }
    }

    private func getPrices() -> [StockPrice] {
        return stocks.first(where: { $0.name == state.rawValue.uppercased() })?.prices ?? []
    }

    // MARK: IAxisValueFormatter Methods
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let prices = getPrices()

        let date = Date(timeIntervalSince1970: prices[Int(value)].timestamp)
        return date.toMonthRepresentableString()
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return ""
    }

    // MARK: ChartViewDelegate Methods
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let prices = getPrices()[Int(entry.x)]

        detailsLabel.text = "O: \(prices.open)  H: \(prices.high)  L: \(prices.low)  C: \(prices.close)"
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        detailsLabel.text = ""
    }
}
