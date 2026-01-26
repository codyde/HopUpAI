//
//  OfflineQueue.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/26/26.
//

import Foundation
import SwiftData
import Network

struct QueueItem: Codable {
    let id: String
    let type: SyncItemType
}

enum SyncItemType: String, Codable {
    case exercise = "exercise"
    case workout = "workout"
    case session = "session"
}

@MainActor
final class OfflineQueue {
    static let shared = OfflineQueue()
    
    private let apiService = APIService.shared
    private let networkMonitor = NetworkMonitor.shared
    
    private init() {}
    
    func enqueue(_ item: String, type: SyncItemType) {
        var queue = getQueue()
        queue.append(QueueItem(id: item, type: type))
        saveQueue(queue)
        
        Task {
            try? await processQueue()
        }
    }
    
    func processQueue() async throws {
        guard networkMonitor.isOnline else { return }
        
        print("Processing offline queue...")
        try await SyncService.shared.uploadPendingChanges()
    }
    
    private func getQueue() -> [QueueItem] {
        guard let data = UserDefaults.standard.data(forKey: "offlineQueue"),
              let queue = try? JSONDecoder().decode([QueueItem].self, from: data) else {
            return []
        }
        return queue
    }
    
    private func saveQueue(_ queue: [QueueItem]) {
        if let data = try? JSONEncoder().encode(queue) {
            UserDefaults.standard.set(data, forKey: "offlineQueue")
        }
    }
}

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isOnline: Bool = true
    private var pathMonitor: NWPathMonitor?
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        pathMonitor = NWPathMonitor()
        let path = pathMonitor!
        
        path.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        path.start(queue: queue)
    }
    
    deinit {
        pathMonitor?.cancel()
    }
}