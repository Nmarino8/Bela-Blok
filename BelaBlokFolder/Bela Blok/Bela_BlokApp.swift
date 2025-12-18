import SwiftUI

@main
struct Bela_BlokApp: App {
    
    @AppStorage("gamesPlayed") private var gamesPlayed: Int = 0
    @AppStorage("gamesWon") private var gamesWon: Int = 0
    @AppStorage("gamesLost") private var gamesLost: Int = 0
    
    init() {
        // Sync gamesPlayed with wins and losses at app launch
        gamesPlayed = gamesWon + gamesLost
    }
    
    var body: some Scene {
        WindowGroup {
            BelaBlokView()
        }
    }
}
