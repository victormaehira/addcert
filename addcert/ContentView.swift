import SwiftUI

struct ContentView: View {
    @State private var statusMessage: String?
    @State private var isError = false
    @State private var isProcessing = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Instalador de Certificado")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Certisign - HSM Remoto")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button(action: performRegistration) {
                Label("Instalar certificado", systemImage: "arrow.down.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isProcessing)

            if let statusMessage {
                Label(
                    statusMessage,
                    systemImage: isError
                        ? "xmark.octagon.fill"
                        : "checkmark.circle.fill"
                )
                .foregroundStyle(isError ? .red : .green)
                .font(.callout)
                .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }

    private func performRegistration() {
        isProcessing = true
        statusMessage = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try TokenRegistration.registerIfPossible()
                DispatchQueue.main.async {
                    statusMessage = "Certificado instalado com sucesso!"
                    isError = false
                    isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = error.localizedDescription
                    isError = true
                    isProcessing = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
