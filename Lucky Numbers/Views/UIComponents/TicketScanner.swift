//
//  TicketScanner.swift
//  JackpotAI
//
//  Created by Matt Willie on 3/18/25.
//

import SwiftUI
import AVFoundation
import UIKit

// MARK: - Ticket Scanner View
struct LotteryTicketScannerView: View {
    @StateObject private var scannerViewModel = TicketScannerViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Camera scanner view
            ScannerView(scannerViewModel: scannerViewModel)
                .ignoresSafeArea()
            
            // Overlay with scan frame and instructions
            scannerOverlay
            
            // Results view appears when scan is successful
            if scannerViewModel.isShowingResults {
                scanResultsView
            }
        }
        .navigationBarTitle("Ticket Scanner", displayMode: .inline)
        .navigationBarItems(trailing: Button("Close") {
            presentationMode.wrappedValue.dismiss()
        })
        .alert(isPresented: $scannerViewModel.showAlert) {
            Alert(
                title: Text(scannerViewModel.alertTitle),
                message: Text(scannerViewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Overlay with scanning frame and instructions
    private var scannerOverlay: some View {
        VStack {
            // Top space
            Spacer()
            
            // Scan frame
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 100)
                    .background(Color.black.opacity(0.1))
                
                // Scanning animation
                if scannerViewModel.isScanning && !scannerViewModel.isShowingResults {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("neonBlue"), lineWidth: 2)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 100)
                        .opacity(scannerViewModel.scanLineOpacity)
                }
                
                Text("Align barcode here")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(4)
                    .offset(y: 60)
            }
            
            // Instructions
            Text("Scan the barcode at the bottom of your lottery ticket")
                .foregroundColor(.white)
                .font(.subheadline)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .padding()
            
            Spacer()
            
            // Scanner controls
            HStack(spacing: 30) {
                Button(action: {
                    scannerViewModel.toggleTorch()
                }) {
                    VStack {
                        Image(systemName: scannerViewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 24))
                        Text("Flash")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    scannerViewModel.isScanning = true
                    scannerViewModel.restartScanning()
                }) {
                    VStack {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 24))
                        Text("Scan")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    // Results view that appears after successful scan
    private var scanResultsView: some View {
        VStack(spacing: 20) {
            // Results card
            VStack(spacing: 15) {
                // Header
                HStack {
                    Image(systemName: "ticket.fill")
                        .foregroundColor(Color("neonBlue"))
                    Text("Ticket Information")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        scannerViewModel.isShowingResults = false
                        scannerViewModel.restartScanning()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // Barcode value
                HStack {
                    Text("Barcode:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(scannerViewModel.scannedCode)
                        .fontWeight(.medium)
                }
                
                // Parsed lottery numbers (if available)
                if !scannerViewModel.parsedNumbers.isEmpty {
                    HStack(alignment: .top) {
                        Text("Numbers:")
                            .foregroundColor(.secondary)
                        Spacer()
                        VStack(alignment: .trailing) {
                            ForEach(scannerViewModel.parsedNumbers, id: \.self) { number in
                                Text(number)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                
                // Game type (if available)
                if !scannerViewModel.gameType.isEmpty {
                    HStack {
                        Text("Game:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(scannerViewModel.gameType)
                            .fontWeight(.medium)
                    }
                }
                
                // Draw date (if available)
                if !scannerViewModel.drawDate.isEmpty {
                    HStack {
                        Text("Draw Date:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(scannerViewModel.drawDate)
                            .fontWeight(.medium)
                    }
                }
                
                Divider()
                
                // Action buttons
                HStack {
                    Button(action: {
                        scannerViewModel.isShowingResults = false
                        scannerViewModel.restartScanning()
                    }) {
                        Text("Scan Another")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        scannerViewModel.saveToFavorites()
                    }) {
                        Text("Save")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color("neonBlue").opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 10)
            .padding()
        }
        .background(Color.black.opacity(0.7))
        .ignoresSafeArea()
    }
}

// MARK: - UIKit Camera Scanner View
struct ScannerView: UIViewRepresentable {
    @ObservedObject var scannerViewModel: TicketScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        scannerViewModel.setupCaptureSession()
        
        let view = UIView(frame: UIScreen.main.bounds)
        
        guard let captureSession = scannerViewModel.captureSession else {
            return view
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Handle updates if needed
    }
}

// MARK: - View Model
class TicketScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var isScanning = true
    @Published var isShowingResults = false
    @Published var isTorchOn = false
    @Published var scanLineOpacity = 1.0
    @Published var scannedCode = ""
    @Published var parsedNumbers: [String] = []
    @Published var gameType = ""
    @Published var drawDate = ""
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    var captureSession: AVCaptureSession?
    private var captureDevice: AVCaptureDevice?
    private var animationTimer: Timer?
    
    override init() {
        super.init()
        startScanAnimation()
    }
    
    func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        self.captureSession = captureSession
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showError(title: "Camera Access", message: "Camera not available on this device")
            return
        }
        
        self.captureDevice = videoCaptureDevice
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showError(title: "Camera Error", message: "Could not access the camera: \(error.localizedDescription)")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showError(title: "Camera Setup", message: "Could not add video input to capture session")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = supportedBarcodeTypes
        } else {
            showError(title: "Scanner Setup", message: "Could not add metadata output to capture session")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }
    
    var supportedBarcodeTypes: [AVMetadataObject.ObjectType] {
        return [
            .upce,
            .code39,
            .code39Mod43,
            .code93,
            .code128,
            .ean8,
            .ean13,
            .aztec,
            .pdf417,
            .itf14,
            .dataMatrix,
            .interleaved2of5,
            .qr
        ]
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard isScanning, !isShowingResults else { return }
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            // Play success sound
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Parse barcode data
            self.scannedCode = stringValue
            parseTicketData(from: stringValue)
            
            // Show results
            isScanning = false
            isShowingResults = true
        }
    }
    
    func parseTicketData(from barcodeValue: String) {
        print("Raw barcode value: \(barcodeValue)") // For debugging
        
        // Clean up the barcode value
        let cleanValue = barcodeValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to determine the lottery type from the barcode format
        if cleanValue.count >= 18 {
            // Different parsing strategies based on barcode length and patterns
            if cleanValue.hasPrefix("PB") || cleanValue.contains("PWRB") {
                gameType = "Powerball"
                parsePowerball(barcode: cleanValue)
            } else if cleanValue.hasPrefix("MM") || cleanValue.contains("MEGA") {
                gameType = "Mega Millions"
                parseMegaMillions(barcode: cleanValue)
            } else if cleanValue.hasPrefix("EU") || cleanValue.contains("EURO") {
                gameType = "EuroMillions"
                parseEuroMillions(barcode: cleanValue)
            } else {
                // Generic parsing for unknown formats
                gameType = "Unknown Game"
                parseGeneric(barcode: cleanValue)
            }
        } else {
            // Barcode is too short for reliable parsing
            parsedNumbers = ["Barcode format not recognized"]
            gameType = "Unknown"
            drawDate = "Unknown"
        }
        
        // If still empty, try alternative parsing methods
        if parsedNumbers.isEmpty {
            // Last resort - try to extract any number sequences
            extractAnyNumbers(from: cleanValue)
        }
    }

    // Parse Powerball format
    private func parsePowerball(barcode: String) {
        // Example Powerball format (simplified)
        var extractedNumbers: [Int] = []
        
        // Try different parsing strategies
        if barcode.count > 20 {
            // Look for number patterns in various parts of the barcode
            for i in stride(from: 8, to: min(barcode.count - 1, 28), by: 2) {
                if let index = barcode.index(barcode.startIndex, offsetBy: i, limitedBy: barcode.endIndex),
                   let nextIndex = barcode.index(index, offsetBy: 2, limitedBy: barcode.endIndex) {
                    let substring = barcode[index..<nextIndex]
                    if let number = Int(substring), number <= 69 {
                        extractedNumbers.append(number)
                    }
                }
            }
        }
        
        formatExtractedNumbers(extractedNumbers, specialBallCount: 1)
        
        // Parse date (example format)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        
        if barcode.count >= 14,
           let dateIndex = barcode.index(barcode.startIndex, offsetBy: 2, limitedBy: barcode.endIndex),
           let endDateIndex = barcode.index(dateIndex, offsetBy: 6, limitedBy: barcode.endIndex) {
            let dateString = String(barcode[dateIndex..<endDateIndex])
            if let date = dateFormatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMMM d, yyyy"
                drawDate = displayFormatter.string(from: date)
            } else {
                drawDate = "Not available"
            }
        }
    }

    // Parse Mega Millions format
    private func parseMegaMillions(barcode: String) {
        // Similar to Powerball but with Mega Millions specific patterns
        // Implementation similar to parsePowerball with adjustments
        var extractedNumbers: [Int] = []
        
        // Try different sections of the barcode
        for i in stride(from: 6, to: min(barcode.count - 1, 26), by: 2) {
            if let index = barcode.index(barcode.startIndex, offsetBy: i, limitedBy: barcode.endIndex),
               let nextIndex = barcode.index(index, offsetBy: 2, limitedBy: barcode.endIndex) {
                let substring = barcode[index..<nextIndex]
                if let number = Int(substring), number <= 70 {
                    extractedNumbers.append(number)
                }
            }
        }
        
        formatExtractedNumbers(extractedNumbers, specialBallCount: 1)
    }

    // Parse EuroMillions format
    private func parseEuroMillions(barcode: String) {
        // EuroMillions specific parsing
        var extractedNumbers: [Int] = []
        
        // Different strategy for EuroMillions
        if barcode.contains("-") {
            let components = barcode.components(separatedBy: "-")
            for component in components {
                if let number = Int(component), number <= 50 {
                    extractedNumbers.append(number)
                }
            }
        } else {
            // Try sequential number extraction
            for i in stride(from: 4, to: min(barcode.count - 1, 24), by: 2) {
                if let index = barcode.index(barcode.startIndex, offsetBy: i, limitedBy: barcode.endIndex),
                   let nextIndex = barcode.index(index, offsetBy: 2, limitedBy: barcode.endIndex) {
                    let substring = barcode[index..<nextIndex]
                    if let number = Int(substring), number <= 50 {
                        extractedNumbers.append(number)
                    }
                }
            }
        }
        
        formatExtractedNumbers(extractedNumbers, specialBallCount: 2)
    }

    // Generic parsing for unknown formats
    private func parseGeneric(barcode: String) {
        var extractedNumbers: [Int] = []
        
        // Look for number patterns anywhere in the barcode
        // Strategy 1: Look for hyphen-separated numbers
        if barcode.contains("-") {
            let components = barcode.components(separatedBy: "-")
            for component in components {
                let trimmed = component.trimmingCharacters(in: .whitespacesAndNewlines)
                if let number = Int(trimmed), number <= 99 {
                    extractedNumbers.append(number)
                }
            }
        }
        
        // Strategy 2: Look for number pairs
        if extractedNumbers.isEmpty {
            for i in stride(from: 0, to: barcode.count - 1, by: 2) {
                if let index = barcode.index(barcode.startIndex, offsetBy: i, limitedBy: barcode.endIndex),
                   let nextIndex = barcode.index(index, offsetBy: 2, limitedBy: barcode.endIndex) {
                    let substring = barcode[index..<nextIndex]
                    if let number = Int(substring), number <= 99 {
                        extractedNumbers.append(number)
                    }
                }
            }
        }
        
        // Format with generic assumption of one special ball
        formatExtractedNumbers(extractedNumbers, specialBallCount: 1)
    }

    // Last resort - try to find any number sequences
    private func extractAnyNumbers(from barcode: String) {
        let pattern = "\\d+"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(barcode.startIndex..., in: barcode)
        var extractedNumbers: [Int] = []
        
        if let matches = regex?.matches(in: barcode, range: range) {
            for match in matches {
                if let range = Range(match.range, in: barcode) {
                    if let number = Int(barcode[range]), number <= 99 {
                        extractedNumbers.append(number)
                    }
                }
            }
        }
        
        formatExtractedNumbers(extractedNumbers, specialBallCount: 1)
    }

    // Format extracted numbers into main and special balls
    private func formatExtractedNumbers(_ numbers: [Int], specialBallCount: Int) {
        guard !numbers.isEmpty else {
            parsedNumbers = ["Could not detect numbers"]
            return
        }
        
        // Sort and remove duplicates
        let uniqueSorted = Array(Set(numbers)).sorted()
        
        if uniqueSorted.count >= 5 + specialBallCount {
            // We have enough numbers for main + special balls
            let mainBalls = uniqueSorted.prefix(5).map { String($0) }.joined(separator: ", ")
            
            if specialBallCount == 1 {
                let specialBall = uniqueSorted[5]
                parsedNumbers = [mainBalls, "Special Ball: \(specialBall)"]
            } else if specialBallCount == 2 && uniqueSorted.count >= 7 {
                let specialBalls = uniqueSorted[5...6].map { String($0) }.joined(separator: ", ")
                parsedNumbers = [mainBalls, "Special Balls: \(specialBalls)"]
            } else {
                parsedNumbers = [mainBalls]
            }
        } else {
            // Not enough numbers, just display what we found
            let allNumbers = uniqueSorted.map { String($0) }.joined(separator: ", ")
            parsedNumbers = [allNumbers]
        }
    }
    
    func formatCurrentDateAsDrawDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: Date())
    }
    
    func toggleTorch() {
        guard let device = captureDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.torchMode == .on {
                device.torchMode = .off
                isTorchOn = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                isTorchOn = true
            }
            
            device.unlockForConfiguration()
        } catch {
            showError(title: "Flash Error", message: "Could not use the flash: \(error.localizedDescription)")
        }
    }
    
    func restartScanning() {
        isScanning = true
        scannedCode = ""
        parsedNumbers = []
        gameType = ""
        drawDate = ""
        
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
        }
    }
    
    func saveToFavorites() {
        // Here you would implement saving the ticket to your app's favorites/storage
        // For example:
        let ticketData = """
        Game: \(gameType)
        Numbers: \(parsedNumbers.joined(separator: " | "))
        Draw Date: \(drawDate)
        """
        
        // Example of saving to UserDefaults (you might use a more robust storage solution)
        var savedTickets = UserDefaults.standard.stringArray(forKey: "savedTickets") ?? []
        savedTickets.append(ticketData)
        UserDefaults.standard.set(savedTickets, forKey: "savedTickets")
        
        self.alertTitle = "Success"
        self.alertMessage = "Ticket saved to favorites"
        self.showAlert = true
    }
    
    private func startScanAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self?.scanLineOpacity = self?.scanLineOpacity == 1.0 ? 0.2 : 1.0
            }
        }
    }
    
    private func showError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    deinit {
        animationTimer?.invalidate()
        captureSession?.stopRunning()
    }
}

// MARK: - Preview
struct LotteryTicketScannerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LotteryTicketScannerView()
        }
    }
}
