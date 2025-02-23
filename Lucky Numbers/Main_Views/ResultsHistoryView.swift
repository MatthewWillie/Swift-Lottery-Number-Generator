//
//  ResultsHistoryView.swift
//  Lucky Numbers
//
//  Created by Matt Willie on 2/19/25.
//

// MARK: - ResultsHistoryView

//struct ResultsHistoryView: View {
//    let gameName: String
//    @State private var history: [LotteryResult] = []
//    
//    var body: some View {
//        ZStack {
//            Color(.systemBackground).ignoresSafeArea()
//            
//            List(history) { result in
//                LotteryCardView(result: result)
//                    .listRowBackground(Color.clear)
//            }
//            .listStyle(PlainListStyle())
//        }
//        .navigationTitle("\(gameName) History")
//        .onAppear { loadHistory() }
//    }
//    
//    private func loadHistory() {
//        DispatchQueue.global(qos: .background).async {
//            let newHistory = (1...10).map { index in
//                LotteryResult(
//                    gameName: gameName,
//                    numbers: randomNumbers(for: gameName),
//                    drawDate: formattedDate(Date().addingTimeInterval(-Double(index) * 86400))
//                )
//            }
//            DispatchQueue.main.async {
//                self.history = newHistory
//            }
//        }
//    }
//    
//    private func randomNumbers(for gameName: String) -> [Int] {
//        if gameName == "Powerball" {
//            let mainNumbers = (1...5).map { _ in Int.random(in: 1...69) }
//            let extra = [Int.random(in: 1...26)]
//            return mainNumbers + extra
//        } else {
//            let mainNumbers = (1...5).map { _ in Int.random(in: 1...70) }
//            let extra = [Int.random(in: 1...25)]
//            return mainNumbers + extra
//        }
//    }
//    
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//}
//
