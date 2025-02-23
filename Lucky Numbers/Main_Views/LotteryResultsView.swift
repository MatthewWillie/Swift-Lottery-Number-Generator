//
//  LotteryResultsView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/18/25.
//

import SwiftUI

// MARK: - Models

struct LotteryResult: Identifiable {
    let id = UUID()
    let gameName: String
    let numbers: [Int]
    let drawDate: String
}

// MARK: - Static Formatters

fileprivate let inputDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

fileprivate let outputDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()

/// Formatter for EuroMillions date format: "Fri, 07 Feb 2025 00:00:00 GMT"
fileprivate let euroMillionsInputFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss 'GMT'"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

// MARK: - Main LotteryResultsView

struct LotteryResultsView: View {
    @State private var recentResults: [LotteryResult] = []
    private let expectedGames = ["Powerball", "Mega Millions", "EuroMillions"]

    var body: some View {
        ZStack {
            // Background color
            Color("lightBlue").ignoresSafeArea()

            // Background image
            Image("background")
                .resizable()
                .ignoresSafeArea()
                .opacity(1)

            GeometryReader { geometry in
                ZStack {
                    // Banner in the background
                    Image("Banner2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .offset(y: -geometry.size.height * 0.01)
                        .zIndex(0)

                    // Cards on top of Banner2
                    ScrollView {
                        LazyVStack(spacing: geometry.size.width * 0) {
                            ForEach(expectedGames, id: \.self) { game in
                                if let result = recentResults.first(where: { $0.gameName == game }) {
                                    NavigationLink(destination: ResultsHistoryView(gameName: result.gameName)) {
                                        LotteryCardView(result: result,
                                                          screenWidth: geometry.size.width,
                                                          showArrow: true) // Pass true to show the arrow
                                            .padding(.vertical, geometry.size.width * 0.015)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    LoadingLotteryCardView(gameName: game)
                                        .frame(width: geometry.size.width * 0.9)
                                        .padding(.vertical, geometry.size.width * 0.015)
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.05)
                    }
                    .frame(height: geometry.size.height * 0.8)
                    .offset(y: geometry.size.height * 0.08)
                    .zIndex(1)
                }
            }
        }
        .onAppear {
            fetchLotteryResults()
        }
    }

    private func fetchLotteryResults() {
        if recentResults.isEmpty {
            fetchPowerballResults { powerballResults in
                let firstPB = powerballResults.first ?? LotteryResult(gameName: "Powerball", numbers: [], drawDate: "No Date")
                DispatchQueue.main.async { self.recentResults.append(firstPB) }
            }
            fetchMegaMillionsResults { megaResults in
                let firstMM = megaResults.first ?? LotteryResult(gameName: "Mega Millions", numbers: [], drawDate: "No Date")
                DispatchQueue.main.async { self.recentResults.append(firstMM) }
            }
            fetchEuroMillionsResults { euroResults in
                let firstEU = euroResults.first ?? LotteryResult(gameName: "EuroMillions", numbers: [], drawDate: "No Date")
                DispatchQueue.main.async { self.recentResults.append(firstEU) }
            }
        }
    }
}

// MARK: - LotteryCardView

struct LotteryCardView: View {
    let result: LotteryResult
    let screenWidth: CGFloat
    var showArrow: Bool = false  // Pass true if you want the arrow

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            // Game Image
            HStack {
                Image(result.gameName)
                    .resizable()
                    .scaledToFit()
                    // Let the height be smaller for compact screens
                    .frame(height: screenWidth * 0.07)
            }
            .padding(.vertical, 4)

            // Winning Numbers
            if result.numbers.isEmpty {
                Text("No numbers found")
                    .foregroundColor(.white)
                    .bold()
                    .font(.system(size: screenWidth * 0.05))
                    .minimumScaleFactor(0.5)  // Shrink text if needed
                    .lineLimit(1)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Winning Numbers:")
                        .bold()
                        .foregroundColor(.white)
                        .font(.system(size: screenWidth * 0.045))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(result.numbers.indices, id: \.self) { idx in
                                let number = result.numbers[idx]
                                let (circleColor, textColor) = styleForNumber(gameName: result.gameName, index: idx)
                                
                                Circle()
                                    .fill(circleColor)
                                    .frame(width: screenWidth * 0.07, height: screenWidth * 0.07)
                                    .overlay(
                                        Text("\(number)")
                                            .foregroundColor(textColor)
                                            .font(.system(size: screenWidth * 0.045))
                                            .bold()
                                            .minimumScaleFactor(0.5)
                                    )
                                    .overlay(
                                        Circle().stroke(Color.yellow, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 1)
                        .padding(.vertical, 1)

                    }
                }
            }

            // Draw Date
            Text("Draw Date: \(result.drawDate)")
                .font(.system(size: screenWidth * 0.035))
                .foregroundColor(Color.white.opacity(0.9))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.9), Color("darkBlue")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.white.opacity(0.2), radius: 2, x: -4, y: -4)
                .shadow(color: Color.black.opacity(0.8), radius: 4, x: 4, y: 4)
        )
        .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.yellow, lineWidth: 2)
                )
        // Let width adapt, remove forced height
        .frame(maxWidth: screenWidth * 0.9)
        .padding(.horizontal, screenWidth * 0.01)
        .overlay(alignment: .topTrailing) {
            if showArrow {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .font(.system(size: screenWidth * 0.06))
                    .padding(.trailing, screenWidth * 0.05)
                    .padding(.top, screenWidth * 0.04)
            }
        }
    }

    private func styleForNumber(gameName: String, index: Int) -> (Color, Color) {
        switch gameName {
        case "Powerball", "Mega Millions":
            return index < 5 ? (.white, .black) : (.red, .white)
        case "EuroMillions":
            return index < 5 ? (.white, .black) : (.yellow, .black)
        default:
            return (.yellow, .black)
        }
    }
}
// MARK: - LoadingLotteryCardView

struct LoadingLotteryCardView: View {
    let gameName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(gameName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            
            HStack {
                Text("Loading Winning Numbers...")
                    .foregroundColor(.white)
                    .italic()
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            Text("Draw Date: --")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.9))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.9), Color("darkBlue")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.white.opacity(0.2), radius: 2, x: -4, y: -4)
                .shadow(color: Color.black.opacity(0.8), radius: 4, x: 4, y: 4)
        )
        .padding([.leading, .trailing], 16)
    }
}

// MARK: - ResultsHistoryView

struct ResultsHistoryView: View {
    let gameName: String
    @State private var history: [LotteryResult] = []
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("darkBlue").opacity(0.3), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .ignoresSafeArea()

            if isLoading {
                LoadingLotteryCardView(gameName: gameName)
                    .padding(.horizontal, 16)
            } else {
                List(history) { result in
                    HStack {
                        Spacer()
                        LotteryCardView(result: result, screenWidth: UIScreen.main.bounds.width)
                            .padding(.vertical, UIScreen.main.bounds.width * 0.0)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                .listRowSpacing(UIScreen.main.bounds.width * 0)
                .listStyle(.plain)
            }
        }
        .navigationTitle("\(gameName) History")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(
            Color("lightGreen").opacity(0.4),
            for: .navigationBar,
            .automatic
        )
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            loadHistory()
        }
    }
    
    private func loadHistory() {
        if gameName == "Powerball" {
            fetchPowerballResults { results in
                DispatchQueue.main.async {
                    self.history = Array(results.prefix(10))
                    self.isLoading = false
                    if self.history.isEmpty {
                        self.history = [LotteryResult(gameName: "Powerball", numbers: [], drawDate: "No Data")]
                    }
                }
            }
        } else if gameName == "Mega Millions" {
            fetchMegaMillionsResults { results in
                DispatchQueue.main.async {
                    self.history = Array(results.prefix(10))
                    self.isLoading = false
                    if self.history.isEmpty {
                        self.history = [LotteryResult(gameName: "Mega Millions", numbers: [], drawDate: "No Data")]
                    }
                }
            }
        } else if gameName == "EuroMillions" {
            fetchEuroMillionsResults { results in
                DispatchQueue.main.async {
                    self.history = Array(results.prefix(10))
                    self.isLoading = false
                    if self.history.isEmpty {
                        self.history = [LotteryResult(gameName: "EuroMillions", numbers: [], drawDate: "No Data")]
                    }
                }
            }
        }
    }
}

// MARK: - Networking

fileprivate func fetchPowerballResults(completion: @escaping ([LotteryResult]) -> Void) {
    guard let url = URL(string: "https://data.ny.gov/api/views/d6yy-54nr/rows.json?accessType=DOWNLOAD") else {
        completion([])
        return
    }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion([])
            return
        }
        do {
            let root = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let dataArr = root?["data"] as? [[Any]] else {
                completion([])
                return
            }
            
            var results: [LotteryResult] = []
            for row in dataArr {
                if row.count > 9,
                   let drawDateStr = row[8] as? String,
                   let winningStr  = row[9] as? String {
                    
                    let dateFormatted = formatDateString(drawDateStr)
                    let parts = winningStr.split(separator: " ").compactMap { Int($0) }
                    let result = LotteryResult(
                        gameName: "Powerball",
                        numbers: parts,
                        drawDate: dateFormatted
                    )
                    results.append(result)
                }
            }
            results.sort { parseDate($0.drawDate) > parseDate($1.drawDate) }
            completion(results)
        } catch {
            completion([])
        }
    }.resume()
}

fileprivate func fetchMegaMillionsResults(completion: @escaping ([LotteryResult]) -> Void) {
    guard let url = URL(string: "https://data.ny.gov/api/views/5xaw-6ayf/rows.json?accessType=DOWNLOAD") else {
        completion([])
        return
    }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion([])
            return
        }
        do {
            let root = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            guard let dataArr = root?["data"] as? [[Any]] else {
                completion([])
                return
            }
            
            var results: [LotteryResult] = []
            for row in dataArr {
                if row.count > 10 {
                    let drawDateStr  = row[8] as? String ?? "NoDate"
                    let winningStr   = row[9] as? String ?? ""
                    let megaBallStr  = row[10] as? String ?? ""
                    
                    let dateFormatted = formatDateString(drawDateStr)
                    let mainNums = winningStr.split(separator: " ").compactMap { Int($0) }
                    let megaNum = parsePossibleInt(megaBallStr)
                    let allNumbers = megaNum != nil ? (mainNums + [megaNum!]) : mainNums
                    
                    let result = LotteryResult(
                        gameName: "Mega Millions",
                        numbers: allNumbers,
                        drawDate: dateFormatted
                    )
                    results.append(result)
                }
            }
            results.sort { parseDate($0.drawDate) > parseDate($1.drawDate) }
            completion(results)
        } catch {
            completion([])
        }
    }.resume()
}

fileprivate func fetchEuroMillionsResults(completion: @escaping ([LotteryResult]) -> Void) {
    guard let url = URL(string: "https://euromillions.api.pedromealha.dev/draws?limit=100") else {
        completion([])
        return
    }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data, error == nil else {
            completion([])
            return
        }
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                completion([])
                return
            }
            
            var results: [LotteryResult] = []
            for obj in jsonArray {
                guard
                    let dateStr   = obj["date"] as? String,
                    let numbers   = obj["numbers"] as? [String],
                    let stars     = obj["stars"] as? [String]
                else {
                    continue
                }
                
                let dateFormatted = formatEuroMillionsDateString(dateStr)
                let mainNums = numbers.compactMap { Int($0) }
                let starNums = stars.compactMap { Int($0) }
                let allNumbers = mainNums + starNums
                
                let result = LotteryResult(
                    gameName: "EuroMillions",
                    numbers: allNumbers,
                    drawDate: dateFormatted
                )
                results.append(result)
            }
            
            results.sort { parseDate($0.drawDate) > parseDate($1.drawDate) }
            completion(results)
        } catch {
            completion([])
        }
    }.resume()
}

// MARK: - Helpers

fileprivate func formatDateString(_ str: String) -> String {
    let dateOnly = str.components(separatedBy: "T").first ?? str
    if let date = inputDateFormatter.date(from: dateOnly) {
        return outputDateFormatter.string(from: date)
    }
    return str
}

fileprivate func formatEuroMillionsDateString(_ str: String) -> String {
    if let date = euroMillionsInputFormatter.date(from: str) {
        return outputDateFormatter.string(from: date)
    }
    return str
}

fileprivate func parseDate(_ str: String) -> Date {
    return outputDateFormatter.date(from: str) ?? Date.distantPast
}

fileprivate func parsePossibleInt(_ raw: String) -> Int? {
    let digitsOnly = raw.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    return Int(digitsOnly)
}

// MARK: - Preview

struct LotteryResultsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LotteryResultsView()
        }
    }
}
