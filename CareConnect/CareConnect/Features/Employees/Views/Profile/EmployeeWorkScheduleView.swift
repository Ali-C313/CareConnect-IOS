//
//  EmployeeWorkScheduleView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation

struct EmployeeWorkScheduleView: View {
    /// Profil-ViewModel
    @EnvironmentObject var vm: EmployeeProfileViewModel
    /// UI-Inhalt
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Arbeitszeiten")
                .font(.headline)
                .foregroundColor(CCDesign.textPrimary)

            HStack {
                Label("\(vm.workSchedule.weeklyHours) Std/Woche",
                      systemImage: "clock")
                Spacer()
                Label("\(vm.workSchedule.shiftStart) – \(vm.workSchedule.shiftEnd)",
                      systemImage: "clock.badge.checkmark")
            }
            .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vm.workSchedule.workDays, id: \.self) { day in
                        Text(day)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(CCDesign.card)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(CCDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(.separator).opacity(0.25),
                radius: 3, x: 0, y: 2)
    }
}