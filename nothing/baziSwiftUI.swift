//
//  baziSwiftUI.swift
//  nothing
//
//  Created by  玉城 on 2024/12/19.
//

import SwiftUI

// 计算立春日期的函数
// 计算立春日期的函数（不四舍五入，返回整数部分和小数部分）
func calculateLiChunDate(for year: Int) -> (Int, Double) {
    // 获取年份的后两位
    let yearLastTwoDigits = year % 100
    
    // 常数 D 和 C
    let D = 0.2422
    let C: Double = 3.87 // 21世纪的C值
    
    // 判断闰年
    let isLeapYear = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))
    let L = isLeapYear ? 1 : 0
    
    // 计算立春日期
    let liChunDate = (Double(yearLastTwoDigits) * D) + C - Double((yearLastTwoDigits - 1) / 4)
    
    // 获取整数部分和小数部分
    let liChunDayInteger = Int(liChunDate) // 整数部分
    let liChunDayDecimal = liChunDate - Double(liChunDayInteger) // 小数部分
    
    return (liChunDayInteger, liChunDayDecimal)
}

// MARK: - 基础数据结构
struct SolarDate: Equatable {
    let year: Int
    let month: Int
    let day: Int
}

struct BaZi {
    let yearGanZhi: String
    let monthGanZhi: String
    let dayGanZhi: String
}

// MARK: - 基础数据
struct ChineseCalendarData {
    // 天干
    static let heavenlyStem = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    
    // 地支
    static let earthlyBranch = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    
    // 基准日期：2024年12月19日 丁巳日
    static let baseDate = SolarDate(year: 2024, month: 12, day: 20)
    static let baseDayGanZhi = (4, 6) // 丁巳日的索引
    static let baseMonthGanZhi = (2, 0) // 丙子月
    static let baseYearGanZhi = (0, 4) // 甲辰年
}

class ChineseCalendarCalculator {
    // MARK: - 计算八字
    func calculateBaZi(from date: SolarDate) -> BaZi {
        // 计算与基准日期的差值
        let daysDiff = calculateDaysDifference(from: ChineseCalendarData.baseDate, to: date)
        let monthsDiff = calculateMonthsDifference(from: ChineseCalendarData.baseDate, to: date)
        
        // 计算日干支
        let (dayStem, dayBranch) = calculateDayGanZhi(daysDiff: daysDiff)
        let dayGanZhi = ChineseCalendarData.heavenlyStem[dayStem] +
                        ChineseCalendarData.earthlyBranch[dayBranch]
        
        // 计算月干支
        let (monthStem, monthBranch) = calculateMonthGanZhi(date: date)
        let monthGanZhi = ChineseCalendarData.heavenlyStem[monthStem] +
                         ChineseCalendarData.earthlyBranch[monthBranch]
        
        let sixtyJiazi = [
            "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "任申", "癸酉",
            "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "任午", "癸未",
            "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "任辰", "癸巳",
            "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "任寅", "癸卯",
            "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "任子", "癸丑",
            "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "任戌", "癸亥"
        ]
        
        
        return BaZi(
            yearGanZhi: "甲辰", // 2024年
            monthGanZhi: monthGanZhi,
            dayGanZhi: dayGanZhi
        )
    }
    
    // MARK: - 计算日干支
    private func calculateDayGanZhi(daysDiff: Int) -> (Int, Int) {
        // 基准日期是丁巳日（天干第4个，地支第6个）
        var stemIndex = ChineseCalendarData.baseDayGanZhi.0 // 4 (丁)
        var branchIndex = ChineseCalendarData.baseDayGanZhi.1 // 6 (巳)
        
        // 处理负数天数差
        if daysDiff < 0 {
            stemIndex = (stemIndex + (daysDiff % 10) + 10) % 10
            branchIndex = (branchIndex + (daysDiff % 12) + 12) % 12
        } else {
            // 处理正数天数差
            stemIndex = (stemIndex + daysDiff) % 10
            branchIndex = (branchIndex + daysDiff) % 12
        }
        
        return (stemIndex, branchIndex)
    }
    
// MARK: - 计算月干支
private func calculateMonthGanZhi(date: SolarDate) -> (Int, Int) {
    // 定义2024-2026年的重要节气日期
    let solarTerms2024: [(month: Int, day: Int, stemIndex: Int, branchIndex: Int)] = [
        (2, 4, 2, 2),   // 立春 丙寅
        (3, 5, 3, 3),   // 惊蛰 丁卯
        (4, 4, 4, 4),   // 清明 戊辰
        (5, 5, 5, 5),   // 立夏 己巳
        (6, 5, 6, 6),   // 芒种 庚午
        (7, 6, 7, 7),   // 小暑 辛未
        (8, 7, 8, 8),   // 立秋 壬申
        (9, 7, 9, 9),   // 白露 癸酉
        (10, 8, 0, 10), // 寒露 甲戌
        (11, 7, 1, 11), // 立冬 乙亥
        (12, 6, 2, 0),  // 大雪 丙子
        (1, 6, 3, 1)    // 小寒 丁丑
    ]
    
    let solarTerms2025: [(month: Int, day: Int, stemIndex: Int, branchIndex: Int)] = [
        (2, 3, 4, 2),   // 立春 戊寅
        (3, 5, 5, 3),   // 惊蛰 己卯
        (4, 4, 6, 4),   // 清明 庚辰
        (5, 5, 7, 5),   // 立夏 辛巳
        (6, 5, 8, 6),   // 芒种 壬午
        (7, 7, 9, 7),   // 小暑 癸未
        (8, 7, 0, 8),   // 立秋 甲申
        (9, 7, 1, 9),   // 白露 乙酉
        (10, 8, 2, 10), // 寒露 丙戌
        (11, 7, 3, 11), // 立冬 丁亥
        (12, 7, 4, 0),  // 大雪 戊子
        (1, 5, 5, 1)    // 小寒 己丑
    ]

    let solarTerms2026: [(month: Int, day: Int, stemIndex: Int, branchIndex: Int)] = [
        (2, 4, 6, 2),   // 立春 庚寅
        (3, 5, 7, 3),   // 惊蛰 辛卯
        (4, 5, 8, 4),   // 清明 壬辰
        (5, 5, 9, 5),   // 立夏 癸巳
        (6, 5, 0, 6),   // 芒种 甲午
        (7, 7, 1, 7),   // 小暑 乙未
        (8, 7, 2, 8),   // 立秋 丙申
        (9, 7, 3, 9),   // 白露 丁酉
        (10, 8, 4, 10), // 寒露 戊戌
        (11, 7, 5, 11), // 立冬 己亥
        (12, 7, 6, 0),  // 大雪 庚子
        (1, 5, 7, 1)    // 小寒 辛丑
    ]
    
    // 根据年份选择对应的节气数据
let solarTerms: [(month: Int, day: Int, stemIndex: Int, branchIndex: Int)]
switch date.year {
    case 2024:
        // 2024年全年使用2024年数据
        solarTerms = solarTerms2024
    case 2025:
        // 2025年2月3日前仍使用2024年数据
        if date.month == 1 || (date.month == 2 && date.day < 3) {
            solarTerms = solarTerms2024
        } else {
            solarTerms = solarTerms2025
        }
    case 2026:
        // 2026年2月4日前仍使用2025年数据
        if date.month == 1 || (date.month == 2 && date.day < 4) {
            solarTerms = solarTerms2025
        } else {
            solarTerms = solarTerms2026
        }
    default:
        // 对于其他年份，暂时使用2024年数据
        solarTerms = solarTerms2024
}
    
    let month = date.month
    let day = date.day
    
    // 查找对应的节气
    var currentTermIndex = 0
    for (index, term) in solarTerms.enumerated() {
        let nextIndex = (index + 1) % solarTerms.count
        let nextTerm = solarTerms[nextIndex]
        
        let currentMonth = term.month
        let currentDay = term.day
        let nextMonth = nextTerm.month
        let nextDay = nextTerm.day
        
        // 判断日期是否在当前节气范围内
        if isDate(month: month, day: day, betweenMonth1: currentMonth, day1: currentDay,
                 month2: nextMonth, day2: nextDay) {
            currentTermIndex = index
            break
        }
    }
    
    // 获取当前节气的天干地支索引
    let term = solarTerms[currentTermIndex]
    return (term.stemIndex, term.branchIndex)
}

// 辅助函数：判断日期是否在两个节气之间
private func isDate(month: Int, day: Int, betweenMonth1: Int, day1: Int,
                   month2: Int, day2: Int) -> Bool {
    let date = month * 100 + day
    let start = betweenMonth1 * 100 + day1
    let end = month2 * 100 + day2
    
    if start < end {
        return date >= start && date < end
    } else {
        // 处理跨年的情况
        return date >= start || date < end
    }
}
    
    // MARK: - 计算日期差
    private func calculateDaysDifference(from baseDate: SolarDate, to targetDate: SolarDate) -> Int {
        if baseDate == targetDate { return 0 }
        
        let calendar = Calendar.current
        let baseComponents = DateComponents(year: baseDate.year,
                                         month: baseDate.month,
                                         day: baseDate.day)
        let targetComponents = DateComponents(year: targetDate.year,
                                           month: targetDate.month,
                                           day: targetDate.day)
        
        guard let baseDate = calendar.date(from: baseComponents),
              let targetDate = calendar.date(from: targetComponents) else {
            return 0
        }
        
        let days = calendar.dateComponents([.day], from: baseDate, to: targetDate).day ?? 0
        return days
    }
    
    // MARK: - 计算月份差
    private func calculateMonthsDifference(from baseDate: SolarDate, to targetDate: SolarDate) -> Int {
        let yearDiff = targetDate.year - baseDate.year
        let monthDiff = targetDate.month - baseDate.month
//        let liChun2025 = calculateLiChunDate(for: 2025)
        // 示例：计算2025年的立春日期
        let (liChun2025Integer, liChun2025Decimal) = calculateLiChunDate(for: 2025)

        // 读取整数部分和小数部分
//        print("2025年立春日期：整数部分：\(liChun2025Integer)，小数部分：\(liChun2025Decimal)")
        // 计算立春时刻
        let timeInHours = liChun2025Decimal * 24 // 小数部分乘以24，得到小时
        let hours = Int(timeInHours) // 小时数
        let minutes = Int((timeInHours - Double(hours)) * 60) // 小时剩余部分乘以60得到分钟数
     
        
//        print("2025年立春日期：整数部分：\(liChun2025Integer)，小数部分：\(liChun2025Decimal)")
//        print("立春时刻：\(hours)小时\(minutes)分钟")

        return yearDiff * 12 + monthDiff
    }
}


// MARK: - SwiftUI 视图
struct ChineseCalendarView: View {
    @State private var selectedDate = Date()
    @State private var baZi: BaZi?
    private let calculator = ChineseCalendarCalculator()
    
    var body: some View {
    
        VStack(spacing: 20) {
            DatePicker(
                "选择日期",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            
            Button("计算八字") {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                
                let solarDate = SolarDate(
                    year: components.year ?? 2024,
                    month: components.month ?? 1,
                    day: components.day ?? 1
                )
                
                baZi = calculator.calculateBaZi(from: solarDate)
            }
            
            if let baZi = baZi {
                VStack(alignment: .leading, spacing: 10) {
                    Text("年柱：\(baZi.yearGanZhi)")
                    Text("月柱：\(baZi.monthGanZhi)")
                    Text("日柱：\(baZi.dayGanZhi)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()



    }
}
#Preview {
    ChineseCalendarView()
}
