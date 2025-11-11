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
            let schedule = vm.workSchedule
            Text("Arbeitszeiten")
                .font(.headline)
                .foregroundColor(CCDesign.textPrimary)

            HStack {
                Label("\(schedule.weeklyHours) Std/Woche", systemImage: "clock")
                Spacer()
                Label("\(schedule.shiftStart) – \(schedule.shiftEnd)", systemImage: "clock.badge.checkmark")
            }
            .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(schedule.workDays, id: \.self) { day in
                        Label(day, systemImage: "sun.max.fill")
                            .labelStyle(.titleOnly)
                            .font(.subheadline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(CCDesign.card.opacity(0.9))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(CCDesign.card.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: CCDesign.textSecondary.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}
