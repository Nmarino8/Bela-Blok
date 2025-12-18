import SwiftUI
import AudioToolbox

struct Round: Codable, Identifiable {
    var id: UUID = UUID()
    var we: Int
    var you: Int
}
struct BelaBlokView: View {
    
    @State private var showingMenuView = false
    @State private var showingSettingsView = false
    @State private var showingAddRoundSheet = false
    @State private var wePointsInput = ""
    @State private var youPointsInput = ""
    @State private var showDeleteAlert = false
    
    @State private var keyboardIsActive = false
    @State private var showingPointsSheet = false
    @State private var totalPoints: Int = 162
    
    @State private var showNewGameAlert = false
    @State private var selectedPoints: Int? = nil
    @State private var showWinnerPopup = false

    @State private var weBelaSelected = false
    @State private var we20Selected = false
    @State private var we50Selected = false
    @State private var we100Selected = false
    @State private var we150Selected = false
    @State private var we200Selected = false

    @State private var youBelaSelected = false
    @State private var you20Selected = false
    @State private var you50Selected = false
    @State private var you100Selected = false
    @State private var you150Selected = false
    @State private var you200Selected = false
    
    @State private var caller: Caller? = .we
    enum Caller {
        case we
        case you
    }

    private var weBonusTotal: Int {
        (weBelaSelected ? 20 : 0) +
        (we20Selected ? 20 : 0) +
        (we50Selected ? 50 : 0) +
        (we100Selected ? 100 : 0) +
        (we150Selected ? 150 : 0) +
        (we200Selected ? 200 : 0)
    }

    private var youBonusTotal: Int {
        (youBelaSelected ? 20 : 0) +
        (you20Selected ? 20 : 0) +
        (you50Selected ? 50 : 0) +
        (you100Selected ? 100 : 0) +
        (you150Selected ? 150 : 0) +
        (you200Selected ? 200 : 0)
    }
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("vibrationsOn") private var vibrationsOn: Bool = true
    
    @AppStorage("weScore") private var weScore: Int = 0
    @AppStorage("youScore") private var youScore: Int = 0
    @AppStorage("roundsData") private var roundsData: Data = Data()
    @AppStorage("maxPoints") private var maxPoints: Int = 1001
    
    @AppStorage("gamesWon") private var gamesWon: Int = 0
    @AppStorage("gamesLost") private var gamesLost: Int = 0
    @AppStorage("SoundOn") private var SoundOn: Bool = true

    
    @State private var rounds: [Round] = []
    
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .trailing) {
                (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 30) {
                    // MARK: gornji dio
                    ZStack {
                        HStack {
                            Button(action: {
                                if vibrationsOn {
                                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                                    generator.impactOccurred()
                                }
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 35))
                                    .foregroundColor(.red)
                            }
                            .alert("Delete block?", isPresented: $showDeleteAlert) {
                                Button("Cancel", role: .cancel) {}
                                Button("Delete", role: .destructive) {
                                    if SoundOn{
                                        AudioServicesPlaySystemSound(SystemSoundID(1160))
                                    }
                                    weScore = 0
                                    youScore = 0
                                    rounds.removeAll()
                                    saveRounds()
                                    maxPoints = 1001
                                }
                            } message: {
                                Text("Are you sure you want to delete the current block and start a new one?")
                            }
                            Spacer()
                        }
                        Text("Bela Blok: \(maxPoints)")
                            .font(.system(size: 23))
                            .bold()
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                showingPointsSheet = true
                            }
                            .sheet(isPresented: $showingPointsSheet) {
                                VStack(spacing: 20) {
                                    Text("Points to Win")
                                        .font(.system(size: 30))
                                        .bold()
                                        .foregroundColor(isDarkMode ? .white : .black)
                                        .padding(.top, 20)
                                    
                                    HStack {
                                        ForEach([501, 701, 1001], id: \.self) { points in
                                            Text("\(points)")
                                                .font(.system(size: 25))
                                                .bold()
                                                .foregroundColor(maxPoints == points ? .white : (isDarkMode ? .white : .black))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(maxPoints == points ? Color.blue : Color.gray.opacity(0.2))
                                                .cornerRadius(12)
                                                .onTapGesture {
                                                    if weScore != 0 || youScore != 0 {
                                                        selectedPoints = points
                                                        showNewGameAlert = true
                                                    } else {
                                                        maxPoints = points
                                                        showingPointsSheet = false
                                                    }
                                                }
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                                .presentationDetents([.medium, .fraction(0.3)])
                                .alert("A game is in progress", isPresented: $showNewGameAlert) {
                                    Button("Start New Game", role: .destructive) {
                                        if let points = selectedPoints {
                                            maxPoints = points
                                            rounds.removeAll()
                                            saveRounds()
                                            weScore = 0
                                            youScore = 0
                                            showingPointsSheet = false
                                        }
                                    }
                                    Button("Cancel", role: .cancel) {
                                        selectedPoints = nil
                                        showingPointsSheet = false
                                    }
                                } message: {
                                    Text("Your current progress will be lost.")
                                }
                            }
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    showingMenuView.toggle()
                                }
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    //MARK: rezultat
                    HStack(spacing: 55){
                        VStack {
                            Text("We")
                                .font(.system(size: 32))
                                .bold()
                            Text("\(weScore)")
                                .font(.system(size: 35))
                                .bold()
                        }
                        .frame(width: 100, height: 100)
                        .background(isDarkMode ? Color.gray.opacity(0.3) : Color.white)
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                        
                        VStack {
                            Text("You")
                                .font(.system(size: 32))
                                .bold()
                            Text("\(youScore)")
                                .font(.system(size: 35))
                                .bold()
                        }
                        .frame(width: 100, height: 100)
                        .background(isDarkMode ? Color.gray.opacity(0.3) : Color.white)
                        .foregroundColor(isDarkMode ? Color.white : Color.black)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                    }
                    Divider()
                        .frame(height: 2)
                        .background(isDarkMode ? Color.white : Color.black)
                        .padding(.horizontal, 16)
                    
                    // MARK: prikazuje runde
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(rounds.indices, id: \.self) { index in
                                let round = rounds[index]
                                HStack {
                                    Text("\(index + 1).")
                                        .font(.system(size: 22))
                                        .bold()
                                        .frame(width: 30, alignment: .leading)
                                    Spacer()
                                    HStack(spacing: 50) {
                                        Text("We: \(round.we)")
                                            .font(.system(size: 22))
                                            .bold()
                                        Text("You: \(round.you)")
                                            .font(.system(size: 22))
                                            .bold()
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(isDarkMode ? Color.white : Color.black)
                                .background(isDarkMode ? Color.gray.opacity(0.3) : Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                .padding(.horizontal, 20)
                            }
                            .padding(.top,5)
                        }
                    }
                    .cornerRadius(12)
                    .layoutPriority(1)
                    
                    //MARK: add round button
                    VStack {
                        Button(action: {
                            if vibrationsOn {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                            if (weScore >= maxPoints && weScore > youScore) || (youScore >= maxPoints && youScore > weScore) {
                                showWinnerPopup = true
                            }else{
                                showingAddRoundSheet = true
                            }
                        }) {
                            Text("Add Round")
                                .font(.system(size: 25, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .sheet(isPresented: $showingAddRoundSheet) {
                        ScrollView{
                            ZStack {
                                (isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                                    .edgesIgnoringSafeArea(.all)
                                    .onTapGesture {
                                        self.hideKeyboard()
                                    }
                                
                                VStack(spacing: 20) {
                                    Text("Add Round")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(isDarkMode ? .white : .black)
                                        .padding(.top, 5)
                                        .padding(.bottom, 5)
                                    
                                    HStack(spacing: 20) {
                                        VStack {
                                            Text("We")
                                                .font(.system(size: 28))
                                                .bold()
                                                .foregroundColor(
                                                    caller == .we ? Color.white : (isDarkMode ? .white : .black)
                                                )
                                                .onTapGesture {
                                                    caller = .we
                                                }
                                                .padding()
                                                .background(caller == .we ? Color.blue : Color.clear)
                                                .cornerRadius(10)
                                            
                                            TextField("0", text: $wePointsInput)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(isDarkMode ? .white : .black)
                                                .padding()
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(10)
                                                // Automatski ažurira drugo polje
                                                .onChange(of: wePointsInput) { oldValue, newValue in
                                                    let wePoints = Int(newValue) ?? 0
                                                    let remaining = totalPoints - wePoints
                                                    youPointsInput = "\(max(remaining, 0))"
                                                }
                                        }
                                        
                                        VStack {
                                            Text("You")
                                                .font(.system(size: 28))
                                                .bold()
                                                .foregroundColor(
                                                    caller == .you ? Color.white : (isDarkMode ? .white : .black)
                                                )
                                                .onTapGesture {
                                                    caller = .you
                                                }
                                                .padding()
                                                .background(caller == .you ? Color.blue : Color.clear)
                                                .cornerRadius(10)
                                            
                                            TextField("0", text: $youPointsInput)
                                                .keyboardType(.numberPad)
                                                .multilineTextAlignment(.center)
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(isDarkMode ? .white : .black)
                                                .padding()
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(10)
                                                // Radi suprotno — ažurira prvo polje
                                                .onChange(of: youPointsInput) { oldValue, newValue in
                                                    let youPoints = Int(newValue) ?? 0
                                                    let remaining = totalPoints - youPoints
                                                    wePointsInput = "\(max(remaining, 0))"
                                                }
                                        }
                                    }
                                    //MARK: Bela zvanja
                                    HStack {
                                        Button(action: {
                                            hideKeyboard()
                                            weBelaSelected.toggle()
                                        }) {
                                            Text("Bela")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(weBelaSelected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                        
                                        Button(action: {
                                            hideKeyboard()
                                            youBelaSelected.toggle()
                                        }) {
                                            Text("Bela")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(youBelaSelected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    }
                                    //MARK: 20 zvanja
                                    HStack {
                                        Button(action: {
                                            hideKeyboard()
                                            we20Selected.toggle()
                                        }) {
                                            Text("20")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(we20Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                        
                                        Button(action: {
                                            hideKeyboard()
                                            you20Selected.toggle()
                                        }) {
                                            Text("20")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(you20Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    }
                                    //MARK: 50 zvanja
                                    HStack {
                                        Button(action: {
                                            hideKeyboard()
                                            we50Selected.toggle()
                                        }) {
                                            Text("50")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(we50Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                        
                                        Button(action: {
                                            hideKeyboard()
                                            you50Selected.toggle()
                                        }) {
                                            Text("50")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(you50Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    }
                                    //MARK: 100 zvanja
                                    HStack {
                                        Button(action: {
                                            hideKeyboard()
                                            we100Selected.toggle()
                                        }) {
                                            Text("100")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(we100Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                        
                                        Button(action: {
                                            hideKeyboard()
                                            you100Selected.toggle()
                                        }) {
                                            Text("100")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(you100Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    }
                                    //MARK: 150 zvanja
                                    HStack {
                                        Button(action: {
                                            hideKeyboard()
                                            we150Selected.toggle()
                                        }) {
                                            Text("150")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(we150Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                        
                                        Button(action: {
                                            hideKeyboard()
                                            you150Selected.toggle()
                                        }) {
                                            Text("150")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(you150Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    }
                                    //MARK: 200 zvanja
                                    HStack {
                                        Button(action: {
                                            hideKeyboard()
                                            we200Selected.toggle()
                                        }) {
                                            Text("200")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(we200Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                        
                                        Button(action: {
                                            hideKeyboard()
                                            you200Selected.toggle()
                                        }) {
                                            Text("200")
                                                .font(.system(size: 22, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(you200Selected ? Color.blue : Color.gray)
                                                .foregroundColor(.white)
                                                .cornerRadius(15)
                                        }
                                        .disabled(keyboardIsActive)
                                        .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    }
                                    
                                    //MARK: confirm button
                                    Button(action: {
                                        hideKeyboard()
                                        if vibrationsOn {
                                            let generator = UIImpactFeedbackGenerator(style: .soft)
                                            generator.impactOccurred()
                                        }
                                        
                                        let weInput = Int(wePointsInput) ?? 0
                                        let youInput = Int(youPointsInput) ?? 0

                                        // Ukupni bodovi uključujući bonus
                                        var wePoints = weInput + weBonusTotal
                                        var youPoints = youInput + youBonusTotal

                                        // Ako oboje imaju 0, nitko ne dobiva bodove
                                        if weInput == 0 && youInput == 0 {
                                            wePoints = 0
                                            youPoints = 0
                                        }
                                        else {
                                            if weInput == 0 && weBonusTotal > 0 {
                                                wePoints = 0
                                                youPoints += weBonusTotal
                                            }
                                            if youInput == 0 && youBonusTotal > 0 {
                                                youPoints = 0
                                                wePoints += youBonusTotal
                                            }
                                            if weInput == 0 {
                                                wePoints = 0
                                                youPoints += 90
                                            }
                                            if youInput == 0 {
                                                youPoints = 0
                                                wePoints += 90
                                            }
                                            
                                            // Provjera situacije kada caller gubi
                                            switch caller {
                                            case .we:
                                                if wePoints < youPoints {
                                                    wePoints = 0
                                                    youPoints = 162 + youBonusTotal + weBonusTotal
                                                }
                                            case .you:
                                                if youPoints < wePoints {
                                                    youPoints = 0
                                                    wePoints = 162 + weBonusTotal + youBonusTotal
                                                }
                                            case .none:
                                                break
                                            }
                                        }

                                        // Dodaj u ukupne rezultate
                                        weScore += wePoints
                                        youScore += youPoints
                                        
                                        if weScore >= maxPoints && weScore > youScore {
                                            gamesWon += 1
                                            showWinnerPopup = true
                                            if SoundOn{
                                                AudioServicesPlaySystemSound(SystemSoundID(1025))
                                            }
                                        } else if youScore >= maxPoints && youScore > weScore {
                                            gamesLost += 1
                                            showWinnerPopup = true
                                            if SoundOn{
                                                AudioServicesPlaySystemSound(SystemSoundID(1025))
                                            }
                                        }
                                        
                                        rounds.append(Round(we: wePoints, you: youPoints))
                                        saveRounds()
                                        
                                        wePointsInput = ""
                                        youPointsInput = ""
                                        weBelaSelected = false
                                        we20Selected = false
                                        we50Selected = false
                                        we100Selected = false
                                        we150Selected = false
                                        we200Selected = false
                                        youBelaSelected = false
                                        you20Selected = false
                                        you50Selected = false
                                        you100Selected = false
                                        you150Selected = false
                                        you200Selected = false
                                        
                                        showingAddRoundSheet = false
                                    }) {
                                        Text("Confirm")
                                            .font(.system(size: 22, weight: .bold))
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                    .disabled(keyboardIsActive)
                                    .opacity(keyboardIsActive ? 0.5 : 1.0)
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                                keyboardIsActive = true
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                                keyboardIsActive = false
                            }
                            //.presentationDragIndicator(.visible)
                        }
                    }
                }
                //MARK: popup za pobjedu
                if showWinnerPopup {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            Text(weScore >= maxPoints ? "We Won!" : "You Won!")
                                .font(.system(size: 35))
                                .bold()
                                .foregroundColor(isDarkMode ? Color.white : Color.white)
                                .padding()
                                .cornerRadius(15)
                        }
                        .frame(width: 250, height: 150)
                        .background(Color.blue)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .transition(.scale)
                        .animation(.spring(), value: showWinnerPopup)
                        .onAppear {
                            // Automatically reset game after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showWinnerPopup = false
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                //MARK: sliding menu
                if showingMenuView {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                showingMenuView = false
                            }
                        }

                    MenuView(onClose: {
                        withAnimation(.easeInOut) {
                            showingMenuView = false
                        }
                    }, onOpenSettings: {
                        withAnimation(.easeInOut) {
                            showingMenuView = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingSettingsView = true
                        }
                    }, onGoHome: {
                        withAnimation(.easeInOut) {
                            showingMenuView = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingSettingsView = false
                            dismiss()
                        }
                    }, onBelaBlok: {
                        withAnimation(.easeInOut) {
                            showingMenuView = false
                        }
                    })
                    .frame(width: geometry.size.width / 2)
                    .frame(maxHeight: .infinity)
                    .background(isDarkMode ? Color(red: 0.1, green: 0.1, blue: 0.12) : Color.white)
                    .shadow(radius: 5)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
            .fullScreenCover(isPresented: $showingSettingsView) {
                SettingsView(onGoHome: {
                    showingSettingsView = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }, onOpenBelaBlok: {
                    showingSettingsView = false
                })
            }
            .onAppear {
                loadRounds()
            }
        }
    }
    func loadRounds() {
        if let decoded = try? JSONDecoder().decode([Round].self, from: roundsData) {
            rounds = decoded
        }
    }

    func saveRounds() {
        if let encoded = try? JSONEncoder().encode(rounds) {
            roundsData = encoded
        }
    }
}
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
