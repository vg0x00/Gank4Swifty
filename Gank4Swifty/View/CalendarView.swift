//
//  CalendarView.swift
//  Gank4Swifty
//
//  Created by vg0x00 on 5/6/18.
//  Copyright © 2018 vg0x00. All rights reserved.
//

import UIKit

class CalendarView: UIView {
    @IBOutlet var leftButton: UIButton!
    @IBOutlet var rightButton: UIButton!
    @IBOutlet var monthLabel: UILabel!
    @IBOutlet var dateCollectionView: UICollectionView!

    var gankDates: [Date?]? {
        didSet {
            initCalendar()
        }
    }

    var currentYear: Int = 2018
    var currentMonth: Int = 1 {
        didSet {
            monthLabel.text = "往日 \(currentYear) - \(currentMonth)"
        }
    }

    var totalDaysShouldDisplayInMonth: Int?
    var firstDayOffset: Int?
    var maxDate: Date?
    var delegate: CalendarViewDelegate?
    var isLoading: Bool = false

    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) {
        let targetOffset = sender.direction.rawValue == 2 ? -1: 1
        updateCalendar(withOffset: targetOffset)
    }

    func updateCalendar(withOffset targetOffset: Int) {
        var targetMonth = currentMonth + targetOffset

        var tempYear = currentYear

        if targetMonth > 12 {
            targetMonth = targetMonth - 12
            tempYear = tempYear + 1
        } else if targetMonth < 1 {
            targetMonth = targetMonth + 12
            tempYear = tempYear - 1
        }
        guard let targetDate = DateUtil.getDate(withString: "\(tempYear)-\(targetMonth)-1", format: "yyyy-MM-dd") else { return }
        let compareResult = targetDate.compare(maxDate!)

        switch compareResult {
        case .orderedDescending:
            print("should not swipe to left")
        default:
            currentYear = tempYear
            currentMonth = targetMonth
            updateCalendarInfo()
            dateCollectionView.reloadData()
        }
    }

    func updateCalendarInfo() {
        firstDayOffset = firstDayPositionOffset
        totalDaysShouldDisplayInMonth = daysCountInMonth + firstDayOffset!
    }

    @IBAction func buttonTapped(sender: UIButton) {
        let targetOffset = sender.tag == 1 ? -1 : 1
        updateCalendar(withOffset: targetOffset)
    }

    func initCalendar() {
        setCalendarTitle()
        updateCalendarInfo()
        dateCollectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setCalendarTitle() {
        guard let gankDates = gankDates,
            let firstDate = gankDates.first, let maxTargetDate = firstDate else { return }
        maxDate = maxTargetDate
        let components = Calendar.current.dateComponents([.year, .month, .day], from: maxTargetDate)
        currentYear = components.year!
        currentMonth = components.month!
        monthLabel.text = "往日 \(currentYear) - \(currentMonth)"
    }
}

extension CalendarView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalDaysShouldDisplayInMonth ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCellId", for: indexPath) as! CalendarCellViewCollectionViewCell
        cell.isHidden = false
        let startOffset = firstDayOffset ?? firstDayPositionOffset
        if indexPath.item < startOffset {
            cell.isHidden = true
        } else {
            cell.button.setTitle("\(indexPath.item - firstDayPositionOffset + 1)", for: .normal)
            if let gankDates = gankDates {
                let currentDate = indexPath.item - startOffset + 1
                let targetDate = DateUtil.getDate(withString: "\(currentYear)-\(currentMonth)-\(currentDate)", format: "yyyy-MM-dd")!
                if gankDates.contains(targetDate) {
                    cell.button.backgroundColor = #colorLiteral(red: 1, green: 0.4980392157, blue: 0.3137254902, alpha: 1)
                    cell.button.setTitleColor(#colorLiteral(red: 0.9450980392, green: 0.9490196078, blue: 0.9647058824, alpha: 1), for: .normal)
                    cell.isUserInteractionEnabled = true
                } else {
                    cell.button.backgroundColor = UIColor.clear
                    cell.button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
                    cell.isUserInteractionEnabled = false
                }
            }
        }
        return cell
    }

}

extension CalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7 - 8
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // get 2018-02-13 string
        if !isLoading {
            isLoading = true
            let targetDateString = "\(currentYear)-\(currentMonth)-\(indexPath.row - (firstDayOffset ?? 0) + 1)"
            delegate?.calendarView(didSelect: targetDateString)
        }
    }
}

extension CalendarView {
    var firstDayPositionOffset: Int {
        guard let date = DateUtil.getDate(withString: "\(self.currentYear)-\(self.currentMonth)-1", format: "yyyy-MM-dd") else { return 0 }
        let firstDayWeekIndex = Calendar.current.ordinality(of: .weekday, in: .weekOfMonth, for: date)

        return firstDayWeekIndex! - 1
    }

    var daysCountInMonth: Int {
        get {
            guard let date = DateUtil.getDate(withString: "\(currentYear)-\(currentMonth)-1", format: "yyyy-MM-dd"),
                let range = Calendar.current.range(of: .day, in: .month, for: date) else { return 0 }
            return range.count
        }
    }
}

protocol CalendarViewDelegate {
    func calendarView(didSelect item: String)
}
