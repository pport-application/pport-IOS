//
//  PortfolioChartCollectionViewCell.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 28.02.2022.
//

import UIKit
import Charts

class PortfolioChartCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func inititialize(dataPoints: [String], values: [Double]) {
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<values.count {
            if i<dataPoints.count {
                let dataEntry1 = PieChartDataEntry(value: values[i], label: dataPoints[i])
                dataEntries.append(dataEntry1)
            } else {
                let dataEntry1 = PieChartDataEntry(value: values[i], label: nil)
                dataEntries.append(dataEntry1)
            }
            
        }

        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        pieChartView.isUserInteractionEnabled = true
        
        pieChartView.noDataText = "No Data Available"
        
        var colors: [UIColor] = []

        for _ in 0..<values.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))

            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        pieChartView.rotationEnabled = false
        pieChartView.legend.enabled = false
        
        pieChartView.delegate = self
    }
    
}

extension PortfolioChartCollectionViewCell: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
}
