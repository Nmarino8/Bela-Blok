import SwiftUI

struct MenuView: View {
    let onClose: () -> Void
    let onOpenSettings: () -> Void
    let onGoHome: () -> Void
    let onBelaBlok: () -> Void
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Menu")
                    .foregroundColor(isDarkMode ? Color.white:Color.black)
                    .font(.system(size: 30))
                    .bold()
            }
            .padding(.top,80)
            
            Divider()
                .frame(height: 2)
                .background(isDarkMode ? Color.white.opacity(1):Color.black.opacity(1) )
            //MARK: home gumb
                Button(action: {
                    onBelaBlok()
                }){
                    Text("Home")
                        .font(.system(size: 25))
                }
                    .buttonStyle(MenuButtonStyle(isDarkMode: isDarkMode))
            
            //MARK: gumb za postavke
                Button(action: {
                    onOpenSettings()
                }){
                    Text("Settings")
                        .font(.system(size: 25))
                }
                    .buttonStyle(MenuButtonStyle(isDarkMode: isDarkMode))
            
            Spacer()
        }
        .padding(.horizontal)
        .background(isDarkMode ? Color(red: 0.08, green: 0.08, blue: 0.1) : Color.white)
        .edgesIgnoringSafeArea(.all) // osigurava da dode odozgora do dole skrina
    }
}


//stil za sve gubove koji su u meniju
struct MenuButtonStyle: ButtonStyle {
    
    var isDarkMode: Bool = false
    @AppStorage("vibrationsOn") private var vibrationsOn: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 22))
            .padding(.vertical, 3)
            .padding(.horizontal, 0)
            .foregroundColor(configuration.isPressed ? .gray : (isDarkMode ? .white : .black))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { oldValue, newValue in
                if newValue {
                    if vibrationsOn{
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
    }
}

#Preview {
    MenuView(
        onClose: {},
        onOpenSettings: {},
        onGoHome: {},
        onBelaBlok: {}
    )
}
