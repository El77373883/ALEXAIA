import SwiftUI

// MARK: - Modelos

struct Saber: Codable, Identifiable {
    var id = UUID()
    var pregunta: String
    var respuesta: String
}

struct Mensaje: Identifiable {
    let id = UUID()
    let texto: String
    let esMio: Bool
}

// MARK: - Cerebro (motor propio, sin librerías de IA)

final class Cerebro: ObservableObject {
    @Published var mensajes: [Mensaje] = []
    @Published var saberes: [Saber] = []
    @Published var nombre: String = ""

    private var pendiente: String? = nil
    private var ultimaPregunta: String? = nil
    private var ultimoSaber: UUID? = nil

    private let vacias: Set<String> = [
        "de", "la", "el", "los", "las", "un", "una", "y", "o", "que",
        "en", "a", "es", "por", "para", "con", "me", "te", "se", "lo", "mi", "tu"
    ]

    init() {
        if let d = UserDefaults.standard.data(forKey: "saberes"),
           let s = try? JSONDecoder().decode([Saber].self, from: d) {
            saberes = s
        } else {
            saberes = Cerebro.iniciales()
            guardar()
        }
        nombre = UserDefaults.standard.string(forKey: "nombre") ?? ""
        mensajes.append(Mensaje(
            texto: "¡Hola! Soy tu IA. Enséñame cosas en la pestaña Enseñar, o aquí con: aprende: pregunta = respuesta",
            esMio: false))
    }

    static func iniciales() -> [Saber] {
        return [
            Saber(pregunta: "hola", respuesta: "¡Hola {nombre}! ¿Cómo estás?"),
            Saber(pregunta: "buenos dias", respuesta: "¡Buenos días {nombre}!"),
            Saber(pregunta: "como estas", respuesta: "Estoy bien, gracias por preguntar. ¿Y tú?"),
            Saber(pregunta: "quien eres", respuesta: "Soy tu IA. Sé lo que tú me enseñas."),
            Saber(pregunta: "gracias", respuesta: "¡De nada!"),
            Saber(pregunta: "adios", respuesta: "¡Hasta luego {nombre}!")
        ]
    }

    // MARK: Guardado

    private func guardar() {
        if let d = try? JSONEncoder().encode(saberes) {
            UserDefaults.standard.set(d, forKey: "saberes")
        }
        UserDefaults.standard.set(nombre, forKey: "nombre")
    }

    func agregar(_ pregunta: String, _ respuesta: String) {
        saberes.append(Saber(pregunta: pregunta, respuesta: respuesta))
        guardar()
    }

    func borrar(_ offsets: IndexSet) {
        saberes.remove(atOffsets: offsets)
        guardar()
    }

    // MARK: Texto

    private func limpiar(_ t: String) -> String {
        let f = t.folding(options: [.diacriticInsensitive, .caseInsensitive],
                          locale: Locale(identifier: "es"))
        return f.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func raices(_ t: String) -> [String] {
        return limpiar(t).split(separator: " ")
            .map { String($0) }
            .filter { !vacias.contains($0) }
            .map { String($0.prefix(5)) }
    }

    private func trigramas(_ s: String) -> Set<String> {
        let c = Array(s)
        if c.count < 3 { return [String(c)] }
        return Set((0...(c.count - 3)).map { String(c[$0..<($0 + 3)]) })
    }

    private func dice<T: Hashable>(_ a: Set<T>, _ b: Set<T>) -> Double {
        if a.isEmpty || b.isEmpty { return 0 }
        return 2.0 * Double(a.intersection(b).count) / Double(a.count + b.count)
    }

    private func rellenar(_ r: String) -> String {
        if nombre.isEmpty {
            return r.replacingOccurrences(of: " {nombre}", with: "")
                    .replacingOccurrences(of: "{nombre}", with: "")
        }
        return r.replacingOccurrences(of: "{nombre}", with: nombre)
    }

    // MARK: Conversación

    func enviar(_ texto: String) {
        let t = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        mensajes.append(Mensaje(texto: t, esMio: true))
        let r = responder(t)
        mensajes.append(Mensaje(texto: r, esMio: false))
    }

    private func responder(_ t: String) -> String {
        let plano = limpiar(t)

        // 1. Estaba esperando que le enseñes una respuesta
        if let p = pendiente {
            pendiente = nil
            if plano == "cancelar" { return "Vale, lo dejamos así." }
            agregar(p, t)
            return "¡Gracias! Ya lo aprendí. Pregúntame de nuevo para probar."
        }

        // 2. Enseñar directo: aprende: pregunta = respuesta
        if plano.hasPrefix("aprende") && t.contains("=") {
            let separadores = CharacterSet(charactersIn: ": ").union(.whitespacesAndNewlines)
            let partes = t.dropFirst(7)
                .split(separator: "=", maxSplits: 1)
                .map { String($0).trimmingCharacters(in: separadores) }
            if partes.count == 2 && !partes[0].isEmpty && !partes[1].isEmpty {
                agregar(partes[0], partes[1])
                return "¡Aprendido! Si te pregunto \"\(partes[0])\", responderé \"\(partes[1])\"."
            }
        }

        // 3. Recordar el nombre
        for pref in ["me llamo ", "mi nombre es "] where plano.hasPrefix(pref) {
            let n = String(t.dropFirst(pref.count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !n.isEmpty {
                nombre = n
                guardar()
                return "¡Mucho gusto, \(n)! Lo recordaré."
            }
        }

        // 4. Olvidar todo
        if plano == "olvida todo" {
            saberes = Cerebro.iniciales()
            nombre = ""
            guardar()
            return "Listo, olvidé todo lo que me enseñaste."
        }

        // 5. Corrección
        let malas: Set<String> = ["mal", "incorrecto", "eso esta mal", "no es asi", "error"]
        if malas.contains(plano), let q = ultimaPregunta {
            if let id = ultimoSaber {
                saberes.removeAll { $0.id == id }
                guardar()
            }
            pendiente = q
            return "Perdón. ¿Cuál sería la respuesta correcta? (o escribe 'cancelar')"
        }

        // 6. Buscar la respuesta más parecida
        let tokens = Set(raices(t))
        let tri = trigramas(plano)
        var puntajes: [(Saber, Double)] = []
        for s in saberes {
            let d1 = dice(tokens, Set(raices(s.pregunta)))
            let d2 = dice(tri, trigramas(limpiar(s.pregunta))) * 0.9
            puntajes.append((s, max(d1, d2)))
        }
        let mejor = puntajes.map { $0.1 }.max() ?? 0
        if mejor >= 0.6 {
            let candidatos = puntajes.filter { $0.1 >= mejor - 0.02 }
            if let elegido = candidatos.randomElement() {
                ultimaPregunta = t
                ultimoSaber = elegido.0.id
                return rellenar(elegido.0.respuesta)
            }
        }

        // 7. No sabe: pide que le enseñes
        pendiente = t
        ultimaPregunta = t
        ultimoSaber = nil
        return "Todavía no sé responder eso. ¿Qué debería contestar? (escribe la respuesta o 'cancelar')"
    }
}

// MARK: - Pantallas

struct ChatView: View {
    @EnvironmentObject var cerebro: Cerebro
    @State private var texto = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(cerebro.mensajes) { m in
                            HStack {
                                if m.esMio { Spacer(minLength: 40) }
                                Text(m.texto)
                                    .padding(10)
                                    .background(m.esMio ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(m.esMio ? .white : .primary)
                                    .cornerRadius(14)
                                if !m.esMio { Spacer(minLength: 40) }
                            }
                            .id(m.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: cerebro.mensajes.count) { _ in
                    if let ultimo = cerebro.mensajes.last {
                        withAnimation { proxy.scrollTo(ultimo.id, anchor: .bottom) }
                    }
                }
            }
            HStack {
                TextField("Escribe aquí...", text: $texto)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(enviar)
                Button(action: enviar) {
                    Image(systemName: "paperplane.fill")
                }
            }
            .padding()
        }
    }

    func enviar() {
        cerebro.enviar(texto)
        texto = ""
    }
}

struct EnsenarView: View {
    @EnvironmentObject var cerebro: Cerebro
    @State private var p = ""
    @State private var r = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Enseñarle algo nuevo") {
                    TextField("Pregunta o frase", text: $p)
                    TextField("Respuesta", text: $r)
                    Button("Guardar") {
                        let pp = p.trimmingCharacters(in: .whitespacesAndNewlines)
                        let rr = r.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !pp.isEmpty && !rr.isEmpty {
                            cerebro.agregar(pp, rr)
                            p = ""
                            r = ""
                        }
                    }
                }
                Section("Lo que sabe (\(cerebro.saberes.count))") {
                    ForEach(cerebro.saberes) { s in
                        VStack(alignment: .leading) {
                            Text(s.pregunta).bold()
                            Text(s.respuesta).foregroundColor(.secondary)
                        }
                    }
                    .onDelete { cerebro.borrar($0) }
                }
            }
            .navigationTitle("Enseñar")
        }
    }
}

// MARK: - App

@main
struct MiIAApp: App {
    @StateObject private var cerebro = Cerebro()

    var body: some Scene {
        WindowGroup {
            TabView {
                ChatView()
                    .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }
                EnsenarView()
                    .tabItem { Label("Enseñar", systemImage: "brain") }
            }
            .environmentObject(cerebro)
        }
    }
}
