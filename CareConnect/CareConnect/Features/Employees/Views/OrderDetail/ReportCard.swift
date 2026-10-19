//
//  ReportCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Leistungsnachweis eines erledigten Auftrags
struct ReportCard: View {
    let report: CompletionReport

    private var info: String {
        [report.completedByName.isBlank ? nil : report.completedByName, report.completedAt?.formattedDateTime]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    var body: some View {
        SectionCard(title: tr("Leistungsnachweis"), icon: "doc.plaintext") {
            Text(report.note)
            if !info.isEmpty {
                Text(info).font(.footnote).foregroundColor(.secondary)
            }
            if report.signature.isBlank {
                Text(tr("Ohne Unterschrift")).font(.footnote).foregroundColor(.secondary)
            } else {
                Label(tr("Unterschrieben von {0}", report.signedBy.ifBlank(tr("Patient"))), systemImage: "signature")
                    .font(.subheadline)
                SignatureView(signature: report.signature)
            }
        }
    }
}

#Preview {
    ReportCard(report: CompletionReport(note: "Verband gewechselt", completedByName: "Ali Chehab"))
        .padding()
        .screenBackground()
}
