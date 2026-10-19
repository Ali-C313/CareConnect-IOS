//
//  SignaturePad.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

// Striche mit Werten von 0 bis 1, damit die Unterschrift in jeder Größe passt
typealias SignatureStrokes = [[CGPoint]]

/// Unterschrift als Text speichern und wieder lesen (gleiches Format wie Android)
enum SignatureCoder {
    /// z. B. "120,450;130,460|..." mit Werten von 0 bis 1000
    static func encode(_ strokes: SignatureStrokes) -> String {
        strokes
            .filter { $0.count > 1 }
            .map { stroke in
                stroke.map { "\(Int(($0.x * 1000).rounded())),\(Int(($0.y * 1000).rounded()))" }
                    .joined(separator: ";")
            }
            .joined(separator: "|")
    }

    static func decode(_ signature: String) -> SignatureStrokes {
        guard !signature.isBlank else { return [] }
        return signature.split(separator: "|").map { stroke in
            stroke.split(separator: ";").compactMap { point in
                let parts = point.split(separator: ",")
                guard parts.count >= 2, let posX = Double(parts[0]), let posY = Double(parts[1]) else { return nil }
                return CGPoint(x: posX / 1000, y: posY / 1000)
            }
        }
    }
}

/// Feld zum Unterschreiben mit dem Finger
struct SignaturePad: View {
    @Binding var strokes: SignatureStrokes
    var height: CGFloat = 180

    @State private var current: [CGPoint] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                if strokes.isEmpty && current.isEmpty {
                    Text(tr("Hier unterschreiben")).foregroundColor(.gray)
                }
                SignatureCanvas(strokes: strokes + [current])
            }
            .contentShape(Rectangle())
            // Vorrang vor dem Scrollen, damit man sauber unterschreiben kann
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        current.append(normalize(value.location, in: geo.size))
                    }
                    .onEnded { _ in
                        if current.count > 1 { strokes.append(current) }
                        current = []
                    }
            )
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.5)))
    }

    private func normalize(_ point: CGPoint, in size: CGSize) -> CGPoint {
        guard size.width > 0, size.height > 0 else { return .zero }
        return CGPoint(x: min(max(point.x / size.width, 0), 1), y: min(max(point.y / size.height, 0), 1))
    }
}

/// Zeigt eine gespeicherte Unterschrift an
struct SignatureView: View {
    let signature: String
    var height: CGFloat = 120

    var body: some View {
        ZStack {
            Color.white
            SignatureCanvas(strokes: SignatureCoder.decode(signature))
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Zeichnet die Striche passend zur Größe
private struct SignatureCanvas: View {
    let strokes: SignatureStrokes

    var body: some View {
        Canvas { context, size in
            for stroke in strokes where stroke.count > 1 {
                var path = Path()
                path.move(to: CGPoint(x: stroke[0].x * size.width, y: stroke[0].y * size.height))
                for point in stroke.dropFirst() {
                    path.addLine(to: CGPoint(x: point.x * size.width, y: point.y * size.height))
                }
                context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

#Preview {
    SignaturePad(strokes: .constant([]))
        .padding()
}
