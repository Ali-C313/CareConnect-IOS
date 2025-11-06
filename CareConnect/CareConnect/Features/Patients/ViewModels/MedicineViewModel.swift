//
//  MedicineViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import Foundation
import Combine

@MainActor
final class MedicineViewModel: ObservableObject {
    @Published var medicines: [MedicineEntry] = []
    @Published var showAddSheet: Bool = false
}
