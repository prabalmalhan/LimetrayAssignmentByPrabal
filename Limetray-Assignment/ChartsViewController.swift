//
//  ChartsViewController.swift
//  Limetray-Assignment
//
//  Created by Prabal Malhan on 4/17/16.
//  Copyright (c) 2016 Prabal Malhan. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ChartsViewController: UIViewController {

    
    @IBOutlet weak var barChart: BarChartView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
 
    var dates: [String]!
    var onlyDates = [String]()
    var numberOfTweets = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dates = ["09","10","11","12","13","14","15","16","17","18","19","20"]
        dataLoad()
        setChart(dates, values: numberOfTweets)

        
    }
    override func viewDidAppear(animated: Bool) {
        dataLoad()
        setChart(dates, values: numberOfTweets)
    }
    func dataLoad(){
        var fetchRequest = NSFetchRequest(entityName: "LimeTrayTweets")
        
        

        // Execute the fetch request
      
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LimeTrayTweets] {
            
            for results in fetchResults{
               
                onlyDates.append(results.date)
            }
            
           
            var i=0
           
            
            for i=0;i<dates.count;i=i+1{
                
                let results = onlyDates.filter { el in el == self.dates[i] }
                
                numberOfTweets.insert(Double(results.count), atIndex: i)
            }
           
            }
    }
    func setChart(dataPoints: [String], values: [Double]) {
        barChart.noDataText = "Please Wait Data is loading"
        barChart.descriptionText = ""
      
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Tweets With Word 'Limetray'")
        let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.joyful()
        barChart.xAxis.labelPosition = .Bottom
        
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChart.data = chartData
        
        
    }

}
