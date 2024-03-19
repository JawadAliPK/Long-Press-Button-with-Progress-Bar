//
//  HoldDownButton.swift
//  LongPressButtonWithProgress
//
//  Created by jawad ali on 19/03/2024.
//

import SwiftUI

struct HoldDownButton: View {
    /// Config
    var text: String
    var paddingHorizontal: CGFloat = 25
    var paddingVertical: CGFloat = 12
    var duration: CGFloat = 1
    var scale: CGFloat = 0.95
    var background: Color
    var loadingTint: Color
    var shape: AnyShape = .init(.capsule)
    var action: () -> ()
    /// View Properties
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    @State private var timerCount: CGFloat = 0
    @State private var progress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var isCompleted: Bool = false
    
    
    
    var body: some View {
        Text(text)
            .padding(.vertical, paddingVertical)
            .padding(.horizontal, paddingHorizontal)
            .background {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(background.gradient)
                    
                    GeometryReader {
                        let size = $0.size
                        
                        Rectangle()
                            .fill(background.gradient)
                        
                        /// Adding Opacity Transition
                        if !isCompleted {
                            Rectangle()
                                .fill(loadingTint)
                                .frame(width: size.width * progress)
                                .transition(.opacity)
                        }
                    }
                }
                
                
            }
            .clipShape(shape)
            .contentShape(shape)
            .scaleEffect(isHolding ? scale : 1)
            .animation(.snappy, value: isHolding)
        /// Gestures
            .gesture(longPressGesture)
            .gesture(dragGesture)
        /// Timer
            .onReceive(timer) { _ in
                if isHolding && progress != 1 {
                    timerCount += 0.01
                    progress = max(min(timerCount / duration, 1), 0)
                }
                
            }
            .onAppear(perform: cancelTimer)
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { _ in
                guard !isCompleted else { return }
                cancelTimer()
                withAnimation(.snappy) {
                    reset()
                }
            }
    }
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: duration)
            .onChanged {
                /// Resetting to initial State
                isCompleted = false
                reset()
                
                isHolding = $0
                addTimer()
            }.onEnded { status in
                isHolding = false
                cancelTimer()
                withAnimation(.easeInOut(duration: 0.2)) {
                    isCompleted = status
                }
                
                action()
            }
    }
    
    /// Adds timer
    func addTimer() {
        timer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    }
    
    /// Cancels Timer
    func cancelTimer() {
        timer.upstream.connect().cancel()
    }
    
    /// Reset to initial state
    func reset() {
        isHolding = false
        progress = 0
        timerCount = 0
    }
}

#Preview {
    ContentView()
}
