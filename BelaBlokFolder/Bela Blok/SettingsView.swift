import SwiftUI

struct SettingsView: View {
    let onGoHome: () -> Void
    let onOpenBelaBlok: () -> Void
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("vibrationsOn") private var vibrationsOn: Bool = true
    @AppStorage("SoundOn") private var SoundOn: Bool = true
    
    @AppStorage("gamesPlayed") private var gamesPlayed: Int = 0
    @AppStorage("gamesWon") private var gamesWon: Int = 0
    @AppStorage("gamesLost") private var gamesLost: Int = 0

    
    @State private var showingMenuView: Bool = false
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                // Background color
                (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .edgesIgnoringSafeArea(.all)
                
                // Main content
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 40))
                            .bold()
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                showingMenuView.toggle()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .padding()
                    
                    // MARK: Dark Mode
                    HStack {
                        Text("Dark Mode:")
                            .font(.system(size: 23))
                            .bold()
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                    }
                    .padding(.horizontal,20)
                    
                    // MARK: Vibrations
                    HStack{
                        Text("Vibrations:")
                            .font(.system(size:23))
                            .bold()
                        Spacer()
                        Toggle("", isOn: $vibrationsOn)
                            .labelsHidden()
                    }
                    .padding(.horizontal,20)
                    .padding(.top, 10)
                    
                    // MARK: Sound
                    HStack{
                        Text("Sound:")
                            .font(.system(size:23))
                            .bold()
                        Spacer()
                        Toggle("", isOn: $SoundOn)
                            .labelsHidden()
                    }
                    .padding(.top, 10)
                    .padding(.horizontal,20)
                    // MARK: - Statistics
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Statistics:")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                        
                        HStack(spacing: 20) {
                            // Left side labels
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Games Played:")
                                Text("Games Won:")
                                    .padding(.top,5)
                                Text("Games Lost:")
                                    .padding(.top,5)
                                Text("Win Rate:")
                                    .padding(.top,5)
                            }
                            
                            Spacer()
                            
                            // Right side values
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("\(gamesPlayed)")
                                Text("\(gamesWon)")
                                    .padding(.top,5)
                                Text("\(gamesLost)")
                                    .padding(.top,5)
                                Text("\(Int(winRate))%")
                                    .padding(.top,5)
                            }
                        }
                        .font(.system(size: 18))
                        .padding()
                        .background(isDarkMode ? Color.gray.opacity(0.2) : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.top,10)
                    .padding(.horizontal, 20)
                    Spacer()
                    
                    //MARK: Footer
                    HStack {
                        Spacer()
                        Text("© 2026 Niko Marinović. All rights reserved.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.bottom, -10)
                }
                .zIndex(0)
                
                // MARK: Floating Menu
                if showingMenuView {
                    // Dimmed background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showingMenuView = false
                            }
                        }
                        .zIndex(1)
                    
                    // Sliding menu
                    MenuView(
                        onClose: {
                            withAnimation(.easeInOut) { showingMenuView = false }
                        },
                        onOpenSettings: {
                            withAnimation(.easeInOut) { showingMenuView = false }
                        },
                        onGoHome: {
                            withAnimation(.easeInOut) { showingMenuView = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onGoHome() }
                        },
                        onBelaBlok: {
                            withAnimation(.easeInOut) { showingMenuView = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onOpenBelaBlok() }
                        }
                    )
                    .frame(width: geometry.size.width / 2)
                    .frame(maxHeight: .infinity)
                    .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .shadow(radius: 5)
                    .transition(.move(edge: .trailing))
                    .zIndex(2)
                }
            }
            .onAppear {
                gamesPlayed = gamesWon + gamesLost
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    SettingsView(onGoHome: { }, onOpenBelaBlok: { })
}
