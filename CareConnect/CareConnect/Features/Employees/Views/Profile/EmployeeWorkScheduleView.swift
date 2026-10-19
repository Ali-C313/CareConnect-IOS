//
//  EmployeeWorkScheduleView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Wochenstunden, Schicht und Arbeitstage
struct EmployeeWorkScheduleView: View {
    let schedule: WorkSchedule

    var body: some View {
        SectionCard(title: tr("Arbeitszeiten"), icon: "clock") {
            InfoRow(system: "hourglass", title: tr("Wochenstunden"), value: tr("{0} Std/Woche", schedule.weeklyHours))
            InfoRow(system: "clock", title: tr("Schicht"), value: "\(schedule.shiftStart) – \(schedule.shiftEnd)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(schedule.workDays, id: \.self) { day in
                        Text(tr(day))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(CCDesign.accent.opacity(0.15), in: Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    EmployeeWorkScheduleView(schedule: WorkSchedule())
        .padding()
        .screenBackground()
}
