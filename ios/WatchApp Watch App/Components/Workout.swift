import SwiftUI

struct WorkoutView: View {
    @State private var selectedPreset = 5  // Default to 5-minute break
    @State private var remainingTime = 5 * 60  // In seconds
    @State private var isRunning = false
    @State private var sets = 1
    @State private var weight = 50.0
    @State private var showWeightInput = false
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            // Timer Display
            Text("Break: \(formatTime(remainingTime))")

            // Sets and Weight Display
            HStack {
                VStack {
                    Text("Weight (kg)")
                    Text("\(String(format: "%.1f", weight))")
                        .font(.title)
                        .focusable()
                }
            }
            .padding()

            // Set Weight Picker
            Button(action: {
                showWeightInput = true
            }) {
                Text("Set Weight")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showWeightInput) {
                WeightPickerView(show: $showWeightInput, weight: $weight)
            }

            // Start/Stop Timer Button
            Button(action: toggleTimer) {
                Text(isRunning ? "Stop Timer" : "Start Timer")
                    .foregroundColor(isRunning ? .red : .green)
                    .padding()
            }
        }
        .onReceive(timer) { _ in
            if isRunning && remainingTime > 0 {
                remainingTime -= 1
            }
        }
    }

    // Toggle start/stop timer
    private func toggleTimer() {
        isRunning.toggle()
    }

    // Reset the timer when the preset is changed
    private func resetTimer() {
        remainingTime = selectedPreset * 60
        isRunning = false
    }

    // Format the remaining time into MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WeightPickerView: View {
    @Binding var show: Bool
    @Binding var weight: Double

    let weights: [Double] = Array(stride(from: 0.0, through: 200.0, by: 0.5))

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Weight (kg)")
                    .font(.headline)
                    .padding()

                Picker("Weight", selection: $weight) {
                    ForEach(weights, id: \.self) { weightValue in
                        Text("\(String(format: "%.1f", weightValue)) kg").tag(weightValue)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)

                Button("Confirm") {
                    show = false
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
           
        }
    }
}

// Preview
#Preview {
    WorkoutView()
}
