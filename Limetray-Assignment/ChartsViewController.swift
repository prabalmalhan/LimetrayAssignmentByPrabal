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
//MARK: LineChart Toggle
    @IBAction func toggle(sender: AnyObject) {
        
        if barChart.hidden == true{
            barChart.hidden = false
            lineChart.hidden = true
        }
        else{
            
            barChart.hidden = true
            lineChart.hidden = false
            setChartData(dates)
        }
    }
    
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var barChart: BarChartView!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
 
    var dates: [String]!
    var onlyDates = [String]()
    var numberOfTweets = [Double]()
    var tweetsFromCoreData = [TwitterFollower]()

//MARK : LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dates = ["09","10","11","12","13","14","15","16","17","18","19","20"]
        dataLoad()
        setChart(dates, values: numberOfTweets)
        
        lineChart.hidden = true

        
    }
    override func viewDidAppear(animated: Bool) {
        dataLoad()
        
        setChart(dates, values: numberOfTweets)
    }
    
//MARK: CoreData Data Load
    func dataLoad(){
        var fetchRequest = NSFetchRequest(entityName: "LimeTrayTweets")
        
        

        // Execute the fetch request
      
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [LimeTrayTweets]
            
        {
            if fetchResults.count != 0{
                
                for results in fetchResults{
                    let alreadyFound = tweetsFromCoreData.filter( { return $0.id == results.id })
                    if alreadyFound.count == 0 {
                        tweetsFromCoreData.append(TwitterFollower(text: results.text, date: results.date, id: results.id))
                        onlyDates.append(results.date)
                    }
                }
            }
           
            var i=0
           
            
            for i=0;i<dates.count;i=i+1{
                
                let results = onlyDates.filter { el in el == self.dates[i] }
                
                numberOfTweets.insert(Double(results.count), atIndex: i)
            }
           
            }
    }
//MARK: BarChart Methods
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
//MARK: LineChart Methods
    func setChartData(dates : [String]) {
        lineChart.noDataText = "Please Wait Data is loading"
        lineChart.descriptionText = ""
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for var i = 0; i < dates.count; i++ {
            yVals1.append(ChartDataEntry(value: numberOfTweets[i], xIndex: i))
        }
        
        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "Tweets With Word 'Limetray'")
        set1.axisDependency = .Left
        set1.setColor(UIColor.redColor().colorWithAlphaComponent(0.5))
        set1.setCircleColor(UIColor.redColor())
        set1.lineWidth = 2.0
        set1.circleRadius = 6.0
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.redColor()
        set1.highlightColor = UIColor.whiteColor()
        set1.drawCircleHoleEnabled = true
        
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        
        let data: LineChartData = LineChartData(xVals: dates, dataSets: dataSets)
        data.setValueTextColor(UIColor.whiteColor())
        
        self.lineChart.data = data
    }


}
