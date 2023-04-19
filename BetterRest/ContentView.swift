//
//  ContentView.swift
//  BetterRest
//
//  Created by Mykola Zakluka on 16.04.2023.
//

import CoreML
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var wakeUo = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    
    private var bedTimeMessage: Text {
        do {
            let conf = MLModelConfiguration()
            let model = try SleepCalculator(configuration: conf)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUo)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUo - prediction.actualSleep
            
            let sleepTimeStyled = Text("\(sleepTime.formatted(date: .omitted, time: .shortened))")
                .foregroundColor(.green)
                .bold()
            
            return Text("Your ideal bedtime is: \(sleepTimeStyled)")
        } catch {
            return  Text("Sorry, there was a problem calculating your bedtime.").foregroundColor(.red)
        }
    }
    
    static private var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    init() {
      let navBarAppearance = UINavigationBar.appearance()
      navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
      navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
            NavigationView {
                ZStack {
                    RadialGradient(stops: [
                        .init(color: Color(red: 166 / 255, green: 123 / 255, blue: 91 / 255), location: 0.2),
                        .init(color: Color(red: 111 / 255, green: 78 / 255, blue: 55 / 255), location: 0.2)
                    ], center: .topTrailing, startRadius: 150, endRadius: 500)
                    .ignoresSafeArea()
                    
                    VStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("When do you want to wake up?")
                                    .font(.headline)
                                
                                DatePicker("Please enter a time", selection: $wakeUo, displayedComponents: .hourAndMinute)
//                                    .labelsHidden()
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                Text("Desired amount of sleep")
                                    .font(.headline)
                                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                Text("Daily coffee intake")
                                    .font(.headline)
                                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()
                        
                        Text("\(bedTimeMessage)")
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                    }
                    .padding()
            }
                .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime() {
        do {
            let conf = MLModelConfiguration()
            let model = try SleepCalculator(configuration: conf)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUo)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUo - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            print(error)
        }
        
        isShowingAlert.toggle()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
 
 VStack {
     VStack(spacing: 0) {
         Text("When do you want to wake up?")
             .font(.headline)
         
         DatePicker("Please enter a time", selection: $wakeUo, displayedComponents: .hourAndMinute)
             .labelsHidden()
             .pickerStyle(.navigationLink)
     }
     
     VStack {
         Text("Desired amount of sleep")
             .font(.headline)
         Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
     }
     
     VStack {
         Text("Daily coffee intake")
             .font(.headline)
         Picker("Select the number of cups", selection: $coffeeAmount) {
             ForEach(1..<21) {
                 Text($0 == 1 ? "1 cup" : "\($0) cups")
             }
         }
         .pickerStyle(.navigationLink)
         .labelsHidden()
     }
 }
 .frame(maxWidth: .infinity)
 .padding(.vertical, 20)
 .background(.thinMaterial)
 .clipShape(RoundedRectangle(cornerRadius: 20))
 .padding()
 */
