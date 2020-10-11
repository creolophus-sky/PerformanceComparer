//
//  MainViewController.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import UIKit
import Charts

class MainViewController: UIViewController, IAxisValueFormatter, IValueFormatter, ChartViewDelegate {
    // MARK: Private Types
    private enum State {
        case week
        case month
    }

    // MARK: Private Properties
    private weak var axisValueFormatter: IAxisValueFormatter?
    private weak var valueFormatter: IValueFormatter?
    private let colors: [UIColor] = [.red, .blue, .green]
    private let request = StockRequest()

    private var weeklyStocks: [Stock] = []
    private var monthlyStocks: [Stock] = []

    private var state: State = .week {
        didSet {
            handleStateChange()
        }
    }

    @IBOutlet private weak var detailsLabel: UILabel!
    @IBOutlet private weak var chartView: LineChartView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        axisValueFormatter = self
        valueFormatter = self
        chartView.xAxis.valueFormatter = axisValueFormatter
        chartView.delegate = self
        getWeeklyStock()
        getMonthlyStock()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? CandlestickChartViewController else { return }

        let currentStock = state == .week ? weeklyStocks : monthlyStocks
        destinationViewController.configure(with: currentStock)
    }

    // MARK: Private Methods
    private func configure(stocks: [Stock]) {
        let data = LineChartData()
        for (index, stock) in stocks.enumerated() {
            guard let endingPrice = stock.prices.last?.close else { continue }
            let dataSet = stock.performanceData.reduce(LineChartDataSet(label: stock.name + ", \( stock.getPerformanceValue(with: endingPrice))")) { result, performanceData in
                let entry = ChartDataEntry(x: performanceData.timestamp, y: performanceData.data, data: "\(performanceData.data)%")
                result.append(entry)
                return result
            }

            dataSet.drawHorizontalHighlightIndicatorEnabled = false
            dataSet.valueFormatter = valueFormatter
            dataSet.colors = [colors[index]]
            dataSet.circleColors = [colors[index]]
            dataSet.circleRadius = 1
            data.addDataSet(dataSet)
        }

        chartView.clear()
        detailsLabel.text = ""
        chartView.data = data
    }

    @IBAction private func segmentedControllerValueChanged(_ sender: Any) {
        guard let segmentedControl = sender as? UISegmentedControl else { return }

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            state = .week
        default:
            state = .month
        }
    }

    private func handleStateChange() {
        switch state {
        case .week:
            self.configure(stocks: weeklyStocks)
        case .month:
            self.configure(stocks: monthlyStocks)
        }
    }

    private func getWeeklyStock() {
        if weeklyStocks.isEmpty {
            request.getWeeklyStock { stocks in
                self.activityIndicator.stopAnimating()
                self.weeklyStocks = stocks
                if self.state == .week {
                    self.configure(stocks: stocks)
                }
            } failure: { error in
                // TODO: show error here
            }
        } else {
            self.configure(stocks: weeklyStocks)
        }
    }

    private func getMonthlyStock() {
        if monthlyStocks.isEmpty {
            request.getMonthlyStock { stocks in
                self.activityIndicator.stopAnimating()
                self.monthlyStocks = stocks
                if self.state == .month {
                    self.configure(stocks: stocks)
                }
            } failure: { error in
                // TODO: show error here
            }
        } else {
            self.configure(stocks: monthlyStocks)
        }
    }

    // MARK: IAxisValueFormatter Methods
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value)
        return date.toMonthRepresentableString()
    }

    // MARK: IValueFormatter Methods
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return ""
    }

    // MARK: ChartViewDelegate Methods
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let stocks = state == .week ? weeklyStocks : monthlyStocks
        let timestamp = entry.x

        var labelText = ""
        for stock in stocks {
            guard let price = stock.prices.first(where: { $0.timestamp == timestamp })?.close else { continue }
            labelText += "\(stock.name) \(stock.getPerformanceValue(with: price))% "
        }

        detailsLabel.text = labelText
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        detailsLabel.text = ""
    }
}
