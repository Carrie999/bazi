//
//  ContentView.swift
//  nothing
//
//  Created by  玉城 on 2024/12/19.
//

import SwiftUI
import Foundation


// 心情数据模型
struct MoodEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mood: Int // 1-5 分别代表不同心情
    let note: String
}

// 心情存储管理器
class MoodStorage: ObservableObject {
    @Published var entries: [MoodEntry] = []
    private let key = "moodEntries"
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func saveEntry(_ newEntry: MoodEntry) {
        // 检查是否存在同一天的记录
        if let index = entries.firstIndex(where: { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: newEntry.date)
        }) {
            // 更新已存在的记录
            entries[index] = newEntry
        } else {
            // 添加新记录
            entries.append(newEntry)
        }
        
        // 保存到本地存储
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}


// 农历工具结构体
struct LunarDateHelper {
    static let chineseNumbers = [
        "初一", "初二", "初三", "初四", "初五",
        "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五",
        "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五",
        "廿六", "廿七", "廿八", "廿九", "三十"
    ]
  
    static let heavenlyStems = [
        "甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"
    ]
  
    static let earthlyBranches = [
        "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"
    ]
    static let sixtyJiazi = [
        "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "任申", "癸酉",
        "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "任午", "癸未",
        "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "任辰", "癸巳",
        "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "任寅", "癸卯",
        "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "任子", "癸丑",
        "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "任戌", "癸亥"
    ]
  
    // 计算年份干支
    static func getYearStemAndBranch(for year: Int) -> (yearStem: String, yearBranch: String) {
        let baseYear = 1984 // 1984年为甲子年
        let offset = year - baseYear
        let yearStemIndex = (offset % 10 + 10) % 10  // 确保负数也能正确取余
        let yearBranchIndex = (offset % 12 + 12) % 12
//        calculateMonthGanZhi(year)
        return (heavenlyStems[yearStemIndex], earthlyBranches[yearBranchIndex])
    }
  
    // 获取农历日期
    static func getLunarDate(for date: Date) -> (lunarDay: String, yearStem: String, monthStem: String, dayStem: String) {
        let calendar = Calendar(identifier: .chinese)
        let components = calendar.dateComponents([.year, .month, .day, .era], from: date)
        let day = components.day ?? 1
        let month = components.month ?? 1
        let year = components.year ?? 1
//        print(date)
//        print("农历年：\(components.year), 月：\(components.month), 日：\(components.day), 纪元：\(components.era)")
//      
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = calendar
      
        // 获取年份的干支
      
        let (yearStem, yearBranch) = getYearStemAndBranch(for: year)
        let yearStemBranch = sixtyJiazi[year-1]
      
        // 计算月干支
       
        let monthStem = sixtyJiazi[month+1]
      
        // 计算日干支
        // 使用农历日期计算日干支：日期加上一个偏移量
        let dayStem = chineseNumbers[day-1]
      
        return (chineseNumbers[day - 1], yearStemBranch, monthStem, dayStem)
    }
}






// 使用方法
//let formatter = DateFormatter()
//formatter.dateFormat = "yyyy/MM/dd HH:mm"
//let date = formatter.date(from: "2000/02/20 23:15")!



//            Text(lunarInfo.yearStem)
//                .font(.system(size: 8))
//            Text(lunarInfo.monthStem)
//                .font(.system(size: 8))
//            Text(lunarInfo.dayStem)
//                .font(.system(size: 8))

//        baZi = calculator.calculateBaZi(from: solarDate)
      
// 单日视图


struct DayView: View {
    @State private var baZi: BaZi?
    private let calculator = ChineseCalendarCalculator()
    let date: Date
    let number: Int
    @State private var showingMoodPopup = false
    @StateObject private var moodStorage = MoodStorage()
    

       // 获取当天的心情记录
    private func getMoodForDate() -> MoodEntry? {
        return moodStorage.entries.first { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    private func moodImageName(_ index: Int) -> String {
            switch index {
            case 1: return "1"
            case 2: return "2"
            case 3: return "3"
            case 4: return "4"
            case 5: return "5"
            default: return ""
            }
        }
    var body: some View {
        let lunarInfo = LunarDateHelper.getLunarDate(for: date)

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let solarDate = SolarDate(
            year: components.year ?? 2024,
            month: components.month ?? 1,
            day: components.day ?? 1
        )

        // 获取今天的日期
        let today = Date()
        let isToday = calendar.isDateInToday(date)
        //心情
        VStack {
//            Text("\(calculator.calculateBaZi(from: solarDate).yearGanZhi)年")
//                .font(.system(size: 8))
            Text("\(calculator.calculateBaZi(from: solarDate).monthGanZhi)月")
                .font(.system(size: 8)) .foregroundColor(isToday ? Color(red: 193 / 255, green: 161 / 255, blue: 68 / 255) : Color(red: 95 / 255, green: 96 / 255, blue: 83 / 255))
            Text("\(calculator.calculateBaZi(from: solarDate).dayGanZhi)日")
                .font(.system(size: 8)) .foregroundColor(isToday ? Color(red: 193 / 255, green: 161 / 255, blue: 68 / 255) : Color(red: 95 / 255, green: 96 / 255, blue: 83 / 255))

            VStack(spacing: 2) {
             // 显示心情图片
                if let mood = getMoodForDate() {
                    Image(moodImageName(mood.mood))
                        .resizable()
                        .frame(width: 45, height: 45)
                        .padding(.top, 2)
                } else {
                    Text("\(number)")
                        .font(.system(size: 14)) .foregroundColor(isToday ? Color(red: 193 / 255, green: 161 / 255, blue: 68 / 255) : Color(red: 183 / 255, green: 184 / 255, blue: 174 / 255))

                }
            
            }
            .frame(width: 45, height: 45)
           .overlay(
                Group {
                    if getMoodForDate() == nil {
                        Circle()
                            .stroke(isToday ? Color(red: 193/255, green: 161/255, blue: 68/255) : Color(red: 183/255, green: 184/255, blue: 174/255), lineWidth: isToday ? 2 : 1)
                    }
                }
            )
             .onTapGesture {
                showingMoodPopup = true
            }
            .sheet(isPresented: $showingMoodPopup) {
                MoodPopupView(
                    isPresented: $showingMoodPopup,
                    date: date,
                    storage: moodStorage
                )
                .presentationDetents([.height(370)]) // 设置固定高度为200
                .presentationDragIndicator(.visible) // 显示顶部拖动指示器
            }

        }
        .onAppear {
            moodStorage.loadEntries()
        }
    }
}



// 心情选择弹出层
struct MoodPopupView: View {
    @Binding var isPresented: Bool
    @State private var selectedMood: Int?
    @State private var note: String = ""
    let date: Date
    @ObservedObject var storage: MoodStorage
    
    var body: some View {
        VStack(spacing: 15) {
            Spacer().frame(height:10)
            Text("今天运势如何？")
                .font(.system(size: 26))
            Spacer().frame(height:20)
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { index in
                    Image(moodImageName(index))
                        .resizable()
                        .frame(width: 60, height: 60)
                        .onTapGesture {
                            selectedMood = index
                        }
                        .overlay(
                            selectedMood == index ?
                            Circle()
                                .stroke(Color.black.opacity(0.8), lineWidth: 2) : nil
                        )
                }
            }
            
            Spacer().frame(height:20)
            TextField("今天发生了什么...", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Spacer().frame(height:50)
            
            Button("确定") {
                if let mood = selectedMood {
                    let entry = MoodEntry(
                        id: UUID(),
                        date: date,
                        mood: mood,
                        note: note
                    )
                    storage.saveEntry(entry)
                }
                isPresented = false
            }
            .disabled(selectedMood == nil)
        }
        .padding()
//        .frame(height: 200)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 0)
    }
    
    private func moodImageName(_ index: Int) -> String {
        switch index {
        case 1: return "1"
        case 2: return "2"
        case 3: return "3"
        case 4: return "4"
        case 5: return "5"
        default: return ""
        }
    }
}



// 月份标题视图
struct MonthTitleView: View {
    let month: Date
    
    var body: some View {
        let lunarInfo = LunarDateHelper.getLunarDate(for: month)
        VStack(spacing: 4) {
            Text(month.formatted(.dateTime.year().month()))
                .font(.title)
//            Text("\(lunarInfo.yearStem)\(lunarInfo.monthStem)")
//                .font(.subheadline)
            Text("\(lunarInfo.yearStem)年")
                .font(.subheadline)
        }
        .padding()
    }
}

// 月份视图
struct MonthView: View {
    let month: Date
    
    // 获取当前月的所有日期
    func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: month)!
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: components) else { return [] }
        
        return (1...range.count).compactMap { day -> Date? in
            var dateComponents = DateComponents()
            dateComponents.year = components.year
            dateComponents.month = components.month
            dateComponents.day = day
            return calendar.date(from: dateComponents)
        }
    }
    
    // 获取当前月的第一天星期几（0=周日，6=周六）
    func getFirstWeekday() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let firstDay = calendar.date(from: components) else { return 0 }
        
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        print("Current Month: \(calendar.component(.month, from: month))")
        print("First Day of Month: \(firstDay)")
        print("Weekday Value: \(weekday)")
        return weekday
    }
    
    var body: some View {
        VStack {
            MonthTitleView(month: month)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // 显示星期
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                }
              
                // 填充前面的空白
                ForEach(0..<getFirstWeekday(), id: \.self) { _ in
                    Color.clear
                }
                
                // 显示日期
                let days = getDaysInMonth()
                ForEach(0..<days.count, id: \.self) { index in
                    DayView(date: days[index], number: index + 1)
                        .id(days[index]) // Ensure each DayView has a unique ID by using the date itself
                }
            }
            .padding()
        }
    }
}


// 主日历视图
struct CalendarView: View {
    @State private var currentMonth = Date()
      @State private var slideOffset: CGFloat = 0 // 添加滑动偏移量状态
    
    var body: some View {
        
        ZStack{
            Image("bg") // 替换为你图片的名字
            .resizable() // 让图片可调整大小
            .scaledToFill() // 让图片填充整个屏幕
            .edgesIgnoringSafeArea(.all)
            .opacity(0.5)
        
            
            // 使图片扩展到整个屏幕，包括安全区域
              VStack {
                Spacer().frame(height: 10)
                MonthView(month: currentMonth)
                    .offset(y: slideOffset)
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let calendar = Calendar.current
                                if value.translation.height > 50 {
                                    // 向下滑动，显示上个月
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        slideOffset = UIScreen.main.bounds.height // 使用屏幕高度
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                                        slideOffset = -UIScreen.main.bounds.height
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            slideOffset = 0
                                        }
                                    }
                                } else if value.translation.height < -50 {
                                    // 向上滑动，显示下个月
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        slideOffset = -UIScreen.main.bounds.height
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                                        slideOffset = UIScreen.main.bounds.height
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            slideOffset = 0
                                        }
                                    }
                                }
                            }
                    )
                
                Spacer()
            }
            .padding()
        }
        
        
        
        
    }
}


struct ContentView: View {
    var body: some View {
        CalendarView()
    }
}
#Preview {
    ContentView()
}
