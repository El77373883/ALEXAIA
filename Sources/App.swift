import SwiftUI
import Security
import UniformTypeIdentifiers

// MARK: - Modelos de datos

struct Saber: Codable, Identifiable {
    var id = UUID()
    var pregunta: String
    var respuesta: String
}

struct Mensaje: Identifiable {
    let id = UUID()
    var texto: String
    let esMio: Bool
    var pensando: Bool = false
}

struct Respaldo: Codable {
    var saberes: [Saber]
    var nombre: String
    var hechos: [String: String]?
}

// MARK: - Modos (estilos de Alexa IA)

enum Modo: String, CaseIterable, Identifiable {
    case veloz, amiga, pro, coach, reflexiva

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .veloz: return "Alexa Veloz"
        case .amiga: return "Alexa Amiga"
        case .pro: return "Alexa Pro"
        case .coach: return "Alexa Coach"
        case .reflexiva: return "Alexa Reflexiva"
        }
    }

    var detalle: String {
        switch self {
        case .veloz: return "Respuestas al instante"
        case .amiga: return "Cercana y con emojis"
        case .pro: return "Formal y profesional"
        case .coach: return "Te impulsa a avanzar"
        case .reflexiva: return "Piensa más y reflexiona"
        }
    }

    var icono: String {
        switch self {
        case .veloz: return "bolt.fill"
        case .amiga: return "face.smiling.fill"
        case .pro: return "briefcase.fill"
        case .coach: return "flag.fill"
        case .reflexiva: return "brain.head.profile"
        }
    }
}

// MARK: - Términos y condiciones

enum Terminos {
    static let secciones: [(String, String)] = [
        ("1. Quién la creó",
         "Alexa IA fue creada por @soyadrianyt001. Al usar la app aceptas estos términos."),
        ("2. Funciona en tu iPhone",
         "Alexa IA funciona sin internet. Lo que escribes y lo que le enseñas se guarda solo en tu dispositivo y no se envía a ningún servidor."),
        ("3. No es un profesional",
         "Las respuestas son orientativas y pueden contener errores. Alexa IA no sustituye a un médico, psicólogo, abogado ni asesor financiero."),
        ("4. Emergencias y bienestar",
         "Si tú o alguien más está en peligro, contacta de inmediato a los servicios de emergencia de tu país o a una persona de confianza. Alexa IA puede acompañarte con palabras, pero no es un servicio de ayuda en crisis."),
        ("5. Tus datos y respaldos",
         "Eres responsable de exportar tu respaldo. Si borras la app o cambia el certificado con el que se instaló, podrías perder lo que le enseñaste."),
        ("6. Uso responsable",
         "No uses Alexa IA para hacer daño, acosar o engañar a otras personas. Tú eres responsable de cómo usas sus respuestas."),
        ("7. Sin afiliación",
         "Alexa IA es una app independiente. No está afiliada, patrocinada ni respaldada por Amazon, Apple ni ninguna otra empresa."),
        ("8. Propiedad",
         "El nombre, el diseño y el código de Alexa IA pertenecen a su creador, @soyadrianyt001. No está permitido hacerse pasar por él ni por la app."),
        ("9. Cambios",
         "Estos términos pueden actualizarse en futuras versiones. Seguir usando la app implica aceptar los cambios."),
        ("10. Sin garantías",
         "La app se ofrece tal cual, sin garantías de funcionamiento continuo ni de exactitud en sus respuestas.")
    ]
}

// MARK: - Llavero (sobrevive al borrar la app, normalmente)

enum Llavero {
    static let servicio = "com.miia.respaldo"

    static func guardar(_ data: Data, clave: String) {
        let base: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: clave
        ]
        SecItemDelete(base as CFDictionary)
        var nuevo = base
        nuevo[kSecValueData as String] = data
        nuevo[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        SecItemAdd(nuevo as CFDictionary, nil)
    }

    static func leer(clave: String) -> Data? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: clave,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var r: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &r) == errSecSuccess else { return nil }
        return r as? Data
    }
}

// MARK: - Documento para exportar/importar

struct RespaldoDoc: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var datos: Data

    init(datos: Data) { self.datos = datos }

    init(configuration: ReadConfiguration) throws {
        datos = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: datos)
    }
}

// MARK: - Calculadora propia

struct Evaluador {
    let c: [Character]
    var i = 0

    init(_ s: String) { c = Array(s.filter { $0 != " " }) }

    mutating func evaluar() -> Double? {
        guard let v = suma(), i == c.count else { return nil }
        return v
    }

    mutating func suma() -> Double? {
        guard var v = producto() else { return nil }
        while i < c.count, c[i] == "+" || c[i] == "-" {
            let op = c[i]
            i += 1
            guard let r = producto() else { return nil }
            v = (op == "+") ? v + r : v - r
        }
        return v
    }

    mutating func producto() -> Double? {
        guard var v = potencia() else { return nil }
        while i < c.count, c[i] == "*" || c[i] == "/" {
            let op = c[i]
            i += 1
            guard let r = potencia() else { return nil }
            v = (op == "*") ? v * r : v / r
        }
        return v
    }

    mutating func potencia() -> Double? {
        guard let b = unario() else { return nil }
        if i < c.count, c[i] == "^" {
            i += 1
            guard let e = potencia() else { return nil }
            return pow(b, e)
        }
        return b
    }

    mutating func unario() -> Double? {
        if i < c.count, c[i] == "-" {
            i += 1
            guard let v = unario() else { return nil }
            return -v
        }
        if i < c.count, c[i] == "+" {
            i += 1
            return unario()
        }
        return primario()
    }

    mutating func primario() -> Double? {
        if i < c.count, c[i] == "(" {
            i += 1
            guard let v = suma(), i < c.count, c[i] == ")" else { return nil }
            i += 1
            return v
        }
        var n = ""
        while i < c.count, c[i].isNumber || c[i] == "." {
            n.append(c[i])
            i += 1
        }
        return Double(n)
    }
}

// MARK: - Emociones

enum Emocion {
    case tristeza, enojo, ansiedad, miedo, soledad, cansancio, aburrimiento, alegria

    var esNegativa: Bool {
        switch self {
        case .tristeza, .enojo, .ansiedad, .miedo, .soledad: return true
        default: return false
        }
    }

    var respuestas: [String] {
        switch self {
        case .tristeza:
            return [
                "Lamento mucho que te sientas así, {nombre} 💙 No tienes que cargar con esto solo; aquí estoy para escucharte. ¿Quieres contarme qué pasó?",
                "Siento que estés pasando por un momento difícil 🫂 Tus sentimientos son válidos. Si quieres, cuéntame qué te tiene así.",
                "Gracias por decírmelo 💙 A veces ponerlo en palabras ayuda. Te leo con calma, cuéntame."
            ]
        case .enojo:
            return [
                "Entiendo que estés molesto 😤 Es válido sentir enojo. Respira hondo conmigo: inhala 4, sostén 4, exhala 6 🌬️ ¿Qué fue lo que pasó?",
                "Uf, suena frustrante 😮‍💨 Desahógate todo lo que quieras, aquí no te voy a juzgar.",
                "Tienes derecho a sentirte así 🔥 Antes de reaccionar, date unos minutos: toma agua, camina un poco. ¿Quieres contarme qué te hizo enojar?"
            ]
        case .ansiedad:
            return [
                "Respira conmigo 🌿 Inhala por la nariz 4 segundos, sostén 4 y suelta despacio 6. Estás a salvo en este momento. ¿Qué te preocupa?",
                "Cuando todo se siente demasiado, ayuda ir paso a paso 🧩 Dime qué es lo más urgente y lo vemos juntos.",
                "Mira a tu alrededor y nombra 5 cosas que ves, 4 que tocas y 3 que oyes 👀 Esto ayuda a volver al presente. ¿Cómo te sientes ahora?"
            ]
        case .miedo:
            return [
                "Es normal sentir miedo, y no tienes que enfrentarlo solo 🕯️ Respira despacio. ¿Qué es lo que te asusta?",
                "Estoy contigo 🤝 Cuéntame qué te da miedo; a veces se ve más pequeño cuando lo decimos en voz alta."
            ]
        case .soledad:
            return [
                "Gracias por confiármelo 💙 Sentirse solo duele, pero en este momento aquí estoy contigo. ¿Quieres que charlemos un rato?",
                "Me alegra que me lo cuentes 🫂 Quizá ayude escribirle a alguien querido. Mientras tanto, cuéntame cómo fue tu día."
            ]
        case .cansancio:
            return [
                "Suena a que necesitas descansar 😴 Toma agua, estírate y, si puedes, duerme un rato. Tu cuerpo te lo agradecerá.",
                "Hiciste mucho hoy 💤 Date permiso de parar un momento."
            ]
        case .aburrimiento:
            return [
                "¡Vamos a arreglar eso! 🎮 Pídeme un chiste, un dato curioso, un pensamiento o una cuenta.",
                "Aburrirse también deja espacio para la creatividad 🎨 ¿Quieres un reto? Dime tres cosas que te gustaría aprender."
            ]
        case .alegria:
            return [
                "¡Qué alegría leerte así, {nombre}! 🎉 Cuéntame qué pasó.",
                "¡Me encanta! ✨ Que esa energía te dure todo el día."
            ]
        }
    }
}

// MARK: - Cerebro (motor propio, sin librerías de IA)

final class Cerebro: ObservableObject {
    @Published var mensajes: [Mensaje] = []
    @Published var saberes: [Saber] = []
    @Published var nombre: String = ""
    @Published var hechos: [String: String] = [:]
    @Published var modo: Modo = .amiga {
        didSet { UserDefaults.standard.set(modo.rawValue, forKey: "modo") }
    }

    private var pendiente: String? = nil
    private var ultimaPregunta: String? = nil
    private var ultimoSaber: UUID? = nil
    private var escuchando = 0

    private let vacias: Set<String> = [
        "de", "la", "el", "los", "las", "un", "una", "y", "o", "que",
        "en", "a", "es", "por", "para", "con", "me", "te", "se", "lo", "mi", "tu"
    ]

    init() {
        if let d = UserDefaults.standard.data(forKey: "saberes"),
           let s = try? JSONDecoder().decode([Saber].self, from: d) {
            saberes = s
            nombre = UserDefaults.standard.string(forKey: "nombre") ?? ""
            if let h = UserDefaults.standard.dictionary(forKey: "hechos") as? [String: String] {
                hechos = h
            }
        } else if let d = Llavero.leer(clave: "respaldo"), restaurar(d) {
            // Recuperado del llavero tras reinstalar
        } else {
            saberes = []
            guardar()
        }
        if let m = UserDefaults.standard.string(forKey: "modo"), let md = Modo(rawValue: m) {
            modo = md
        }
    }

    // MARK: Guardado

    private func guardar() {
        if let d = try? JSONEncoder().encode(saberes) {
            UserDefaults.standard.set(d, forKey: "saberes")
        }
        UserDefaults.standard.set(nombre, forKey: "nombre")
        UserDefaults.standard.set(hechos, forKey: "hechos")
        if let r = datosRespaldo() {
            Llavero.guardar(r, clave: "respaldo")
        }
    }

    func datosRespaldo() -> Data? {
        return try? JSONEncoder().encode(Respaldo(saberes: saberes, nombre: nombre, hechos: hechos))
    }

    func restaurar(_ d: Data) -> Bool {
        guard let r = try? JSONDecoder().decode(Respaldo.self, from: d) else { return false }
        saberes = r.saberes
        nombre = r.nombre
        hechos = r.hechos ?? [:]
        guardar()
        return true
    }

    func agregar(_ pregunta: String, _ respuesta: String) {
        saberes.append(Saber(pregunta: pregunta, respuesta: respuesta))
        guardar()
    }

    func borrar(_ offsets: IndexSet) {
        saberes.remove(atOffsets: offsets)
        guardar()
    }

    func nuevaConversacion() {
        mensajes = []
        pendiente = nil
        ultimaPregunta = nil
        ultimoSaber = nil
        escuchando = 0
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

    private func puntaje(_ tokens: Set<String>, _ tri: Set<String>, _ pregunta: String) -> Double {
        let d1 = dice(tokens, Set(raices(pregunta)))
        let d2 = dice(tri, trigramas(limpiar(pregunta))) * 0.8
        return max(d1, d2)
    }

    private func rellenar(_ r: String) -> String {
        if nombre.isEmpty {
            return r.replacingOccurrences(of: " {nombre}", with: "")
                    .replacingOccurrences(of: "{nombre}", with: "")
        }
        return r.replacingOccurrences(of: "{nombre}", with: nombre)
    }

    private func sinEmojis(_ s: String) -> String {
        let f = s.unicodeScalars.filter {
            !$0.properties.isEmojiPresentation && $0.value != 0xFE0F && $0.value != 0x200D
        }
        let r = String(String.UnicodeScalarView(f))
        return r.replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespaces)
    }

    // MARK: Herramientas

    private func calcular(_ t: String) -> String? {
        var s = t.folding(options: [.diacriticInsensitive, .caseInsensitive],
                          locale: Locale(identifier: "es"))
        s = " " + s + " "
        let cambios: [(String, String)] = [
            (" mas ", "+"), (" menos ", "-"), (" por ", "*"),
            (" entre ", "/"), (" dividido ", "/"), (" x ", "*")
        ]
        for (a, b) in cambios {
            s = s.replacingOccurrences(of: a, with: b)
        }
        let permitidas: Set<String> = [
            "cuanto", "cuanta", "cuantos", "es", "son", "calcula", "calcular",
            "resultado", "de", "resuelve", "dime", "la", "el", "a", "seria"
        ]
        let palabras = s.components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
        for p in palabras where !permitidas.contains(p) { return nil }

        let comas = s.replacingOccurrences(of: ",", with: ".")
        let expr = String(comas.filter { "0123456789+-*/().^ ".contains($0) })
            .trimmingCharacters(in: .whitespaces)
        guard expr.contains(where: { $0.isNumber }),
              expr.contains(where: { "+-*/^".contains($0) }) else { return nil }

        var ev = Evaluador(expr)
        guard let v = ev.evaluar() else { return nil }
        if !v.isFinite { return "Eso no se puede calcular 🤔 (¿dividiste entre cero?)" }

        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 6
        f.locale = Locale(identifier: "es_MX")
        let texto = f.string(from: NSNumber(value: v)) ?? "\(v)"
        return "🧮 El resultado es \(texto)."
    }

    private func fechaHora(_ plano: String) -> String? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        if plano.contains("que hora") || plano.contains("la hora") || plano == "hora" {
            f.dateFormat = "h:mm a"
            return "⏰ Son las \(f.string(from: Date()))."
        }
        if plano.contains("que dia es") || plano.contains("que fecha") ||
            plano.contains("fecha de hoy") || plano.contains("en que dia estamos") {
            f.dateFormat = "EEEE d 'de' MMMM 'de' yyyy"
            let s = f.string(from: Date())
            return "📅 Hoy es \(s.prefix(1).uppercased() + s.dropFirst())."
        }
        return nil
    }

    // MARK: Emociones y seguridad

    private func esCrisis(_ plano: String) -> Bool {
        let frases = [
            "suicid", "quiero morir", "quiero morirme", "no quiero vivir",
            "matarme", "quitarme la vida", "terminar con mi vida",
            "acabar con mi vida", "hacerme dano", "lastimarme",
            "no vale la pena vivir"
        ]
        return frases.contains(where: { plano.contains($0) })
    }

    private let textoCrisis = "Siento mucho que estés pasando por algo tan doloroso 💙 Me importa que estés a salvo.\n\nPor favor, habla ahora mismo con alguien de confianza o llama a los servicios de emergencia de tu país. Si estás en México, la Línea de la Vida atiende las 24 horas al 800 911 2000.\n\nNo tienes que pasar por esto en soledad. ¿Hay alguien cerca que pueda acompañarte?"

    private func detectarEmocion(_ plano: String) -> Emocion? {
        let marcadores = [
            "estoy", "ando", "me siento", "siento", "me puse", "me da",
            "tengo", "me enoje", "me molesta", "me hace sentir"
        ]
        guard marcadores.contains(where: { plano.contains($0) }) else { return nil }
        let palabras = Set(plano.split(separator: " ").map { String($0) })

        func hay(_ lista: [String]) -> Bool {
            return lista.contains(where: { palabras.contains($0) })
        }

        if hay(["solo", "sola", "soledad"]) && !plano.contains("solo quiero") { return .soledad }
        if hay(["triste", "tristeza", "llorar", "llorando", "deprimido", "deprimida",
                "depresion", "desanimado", "desanimada", "decaido", "decaida",
                "fatal", "destrozado", "destrozada", "vacio", "vacia"])
            || plano == "estoy mal" || plano.contains("me siento mal")
            || plano.contains("me siento muy mal") { return .tristeza }
        if hay(["enojado", "enojada", "furioso", "furiosa", "molesto", "molesta",
                "harto", "harta", "rabia", "enfadado", "enfadada", "odio",
                "coraje", "irritado", "irritada", "enoje"]) { return .enojo }
        if hay(["ansioso", "ansiosa", "ansiedad", "nervioso", "nerviosa",
                "preocupado", "preocupada", "estresado", "estresada", "estres",
                "agobiado", "agobiada", "presionado", "presionada"]) { return .ansiedad }
        if hay(["miedo", "asustado", "asustada", "temor", "pavor"]) { return .miedo }
        if hay(["cansado", "cansada", "agotado", "agotada", "sueno"]) { return .cansancio }
        if hay(["aburrido", "aburrida", "aburrimiento"]) { return .aburrimiento }
        if hay(["feliz", "contento", "contenta", "emocionado", "emocionada",
                "alegre", "genial", "motivado", "motivada"]) { return .alegria }
        return nil
    }

    private let oyentes: [String] = [
        "Te escucho, {nombre} 💙 Cuéntame más, sin prisa.",
        "Gracias por confiar en mí. Lo que sientes importa. ¿Qué crees que lo provocó?",
        "Entiendo 🫂 A veces ponerlo en palabras ya ayuda un poquito. ¿Qué necesitas ahora: desahogarte, un consejo o distraerte?",
        "Suena pesado. Respira hondo conmigo: inhala 4, sostén 4, exhala 6 🌬️ ¿Qué es lo que más te pesa de todo esto?"
    ]

    // MARK: Estilo según el modo

    private func estilizar(_ r: String) -> String {
        switch modo {
        case .veloz:
            return r
        case .amiga:
            let extra = ["😊", "✨", "😄", "🙌", "💙"].randomElement() ?? "😊"
            return r.count < 220 ? r + " " + extra : r
        case .pro:
            return sinEmojis(r)
        case .coach:
            let c = [
                "🎯 Reto de hoy: da un pequeño paso ahora mismo.",
                "💪 Tú puedes con esto.",
                "🔥 La constancia vale más que la perfección."
            ].randomElement() ?? ""
            return r + "\n\n" + c
        case .reflexiva:
            let ini = ["💭 Hmm, déjame pensarlo… ", "💭 Interesante… ", "💭 Veamos… "].randomElement() ?? ""
            let fin = [
                "🌱 Piénsalo un momento: ¿qué te dice esto a ti?",
                "🧠 A veces la mejor respuesta nace de una buena pregunta.",
                "✨ Lo que parece pequeño hoy puede cambiar mucho mañana."
            ].randomElement() ?? ""
            return ini + r + "\n\n" + fin
        }
    }

    // MARK: Conversación

    func enviar(_ texto: String) {
        let t = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        mensajes.append(Mensaje(texto: t, esMio: true))

        let plano = limpiar(t)
        var respuesta: String
        if esCrisis(plano) {
            pendiente = nil
            escuchando = 0
            respuesta = textoCrisis
        } else {
            let r = responder(t)
            respuesta = (pendiente != nil) ? r : estilizar(r)
        }

        let marcador = Mensaje(texto: "", esMio: false, pensando: true)
        mensajes.append(marcador)

        let espera: Double
        switch modo {
        case .veloz: espera = 0.25
        case .reflexiva: espera = min(3.0, 1.2 + Double(respuesta.count) / 100.0)
        default: espera = min(2.0, 0.6 + Double(respuesta.count) / 120.0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + espera) { [weak self] in
            guard let self = self else { return }
            if let i = self.mensajes.firstIndex(where: { $0.id == marcador.id }) {
                self.mensajes[i].texto = respuesta
                self.mensajes[i].pensando = false
            }
        }
    }

    private func responder(_ t: String) -> String {
        let plano = limpiar(t)

        // 1. Estaba esperando que le enseñes una respuesta
        if let p = pendiente {
            pendiente = nil
            if plano == "cancelar" { return "Vale, lo dejamos así 👍" }
            agregar(p, t)
            return "¡Gracias! Ya lo aprendí 🎓 Pregúntame de nuevo para probar."
        }

        // 2. Enseñar directo: aprende: pregunta = respuesta
        if plano.hasPrefix("aprende") && t.contains("=") {
            let separadores = CharacterSet(charactersIn: ": ").union(.whitespacesAndNewlines)
            let partes = t.dropFirst(7)
                .split(separator: "=", maxSplits: 1)
                .map { String($0).trimmingCharacters(in: separadores) }
            if partes.count == 2 && !partes[0].isEmpty && !partes[1].isEmpty {
                agregar(partes[0], partes[1])
                return "¡Aprendido! 🎓 Si me preguntas \"\(partes[0])\", responderé \"\(partes[1])\"."
            }
        }

        // 3. Recordar el nombre
        for pref in ["me llamo ", "mi nombre es "] where plano.hasPrefix(pref) {
            let n = String(t.dropFirst(pref.count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !n.isEmpty {
                nombre = n
                guardar()
                return "¡Mucho gusto, \(n)! 🤝 Lo recordaré."
            }
        }

        // 4. Olvidar todo
        if plano == "olvida todo" {
            saberes = []
            hechos = [:]
            nombre = ""
            guardar()
            return "Listo, olvidé todo lo que me enseñaste 🧹"
        }

        // 5. Corrección
        let malas: Set<String> = ["mal", "incorrecto", "eso esta mal", "no es asi", "error"]
        if malas.contains(plano), let q = ultimaPregunta {
            if let id = ultimoSaber {
                saberes.removeAll { $0.id == id }
                guardar()
            }
            pendiente = q
            return "Perdón 🙏 ¿Cuál sería la respuesta correcta? (o escribe 'cancelar')"
        }

        // 6. Cuentas
        if let r = calcular(t) { return r }

        // 7. Hora y fecha
        if let r = fechaHora(plano) { return r }

        // 8. Emociones
        if let e = detectarEmocion(plano) {
            escuchando = e.esNegativa ? 2 : 0
            return rellenar(e.respuestas.randomElement() ?? "")
        }

        // 9. Lo que sé de ti
        if plano == "que sabes de mi" || plano == "que recuerdas de mi" {
            var datos: [String] = []
            if !nombre.isEmpty { datos.append("te llamas \(nombre)") }
            for (k, v) in hechos.sorted(by: { $0.key < $1.key }) {
                datos.append("tu \(k) es \(v)")
            }
            if datos.isEmpty {
                return "Todavía no sé nada de ti 🤔 Dime, por ejemplo: mi color favorito es azul."
            }
            return "Sé que " + datos.joined(separator: ", ") + " 💙"
        }

        // 10. Preguntas sobre tus datos: "cuál es mi ..."
        if plano.hasPrefix("cual es mi ") {
            let clave = String(plano.dropFirst("cual es mi ".count))
            if clave == "nombre" {
                return nombre.isEmpty ? "Aún no me has dicho tu nombre 🤔 Dime: me llamo ..." : "Te llamas \(nombre) 😊"
            }
            if let v = hechos[clave] { return "Tu \(clave) es \(v) 😊" }
            return "Aún no me has dicho cuál es tu \(clave) 🤔 Dime: mi \(clave) es ..."
        }

        // 11. Aprender datos tuyos: "mi X es Y"
        if plano.hasPrefix("mi ") {
            let sinMi = String(plano.dropFirst(3))
            if let r = sinMi.range(of: " es "),
               let rt = t.range(of: " es ", options: .caseInsensitive) {
                let clave = String(sinMi[..<r.lowerBound])
                let valor = String(t[rt.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !clave.isEmpty && !valor.isEmpty {
                    hechos[clave] = valor
                    guardar()
                    return "Anotado 📝 Tu \(clave) es \(valor). Lo recordaré."
                }
            }
        }

        // 12. Seguir escuchando después de una emoción difícil
        if escuchando > 0 {
            let salidas = ["gracias", "mejor", "adios", "chiste", "dato", "pensamiento"]
            if salidas.contains(where: { plano.contains($0) }) {
                escuchando = 0
            } else {
                escuchando -= 1
                return rellenar(oyentes.randomElement() ?? "")
            }
        }

        // 13. Buscar la respuesta más parecida (primero lo que tú me enseñaste)
        let tokens = Set(raices(t))
        let tri = trigramas(plano)
        var puntajes: [(Saber, Double)] = []
        for s in saberes {
            puntajes.append((s, puntaje(tokens, tri, s.pregunta) + 0.03))
        }
        for s in Conocimiento.base {
            puntajes.append((s, puntaje(tokens, tri, s.pregunta)))
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

        if mejor >= 0.5 {
            if let elegido = puntajes.first(where: { $0.1 == mejor }) {
                ultimaPregunta = t
                ultimoSaber = elegido.0.id
                return "Tengo mis dudas 🤔 pero creo que preguntas por \"\(elegido.0.pregunta)\". Te diría: \(rellenar(elegido.0.respuesta)) Si no era eso, dime \"mal\" y me enseñas."
            }
        }

        // 14. No sabe: pide que le enseñes
        pendiente = t
        ultimaPregunta = t
        ultimoSaber = nil
        return "Todavía no sé responder eso 🤔 pero quiero aprenderlo. ¿Qué debería contestar? (escribe la respuesta o 'cancelar')"
    }
}

// MARK: - Componentes visuales

struct Orbe: View {
    var tam: CGFloat = 120
    @State private var gira = false
    @State private var late = false

    var body: some View {
        ZStack {
            Circle()
                .fill(AngularGradient(
                    colors: [.purple, .blue, .cyan, .mint, .purple],
                    center: .center))
                .rotationEffect(.degrees(gira ? 360 : 0))
                .blur(radius: tam * 0.03)
            Circle()
                .fill(Color.black.opacity(0.28))
                .padding(tam * 0.14)
            Image(systemName: "sparkles")
                .font(.system(size: tam * 0.36, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: tam, height: tam)
        .scaleEffect(late ? 1.05 : 0.95)
        .onAppear {
            withAnimation(.linear(duration: 7).repeatForever(autoreverses: false)) {
                gira = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                late = true
            }
        }
    }
}

struct AvatarIA: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [.purple, .blue],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 28, height: 28)
    }
}

struct Puntos: View {
    @State private var fase = 0
    let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .frame(width: 8, height: 8)
                    .opacity(fase == i ? 1 : 0.25)
            }
        }
        .padding(.vertical, 9)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.25)) { fase = (fase + 1) % 3 }
        }
    }
}

struct FilaMensaje: View {
    let m: Mensaje

    var body: some View {
        if m.esMio {
            HStack {
                Spacer(minLength: 50)
                Text(m.texto)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .textSelection(.enabled)
            }
        } else {
            HStack(alignment: .top, spacing: 10) {
                AvatarIA()
                if m.pensando {
                    Puntos()
                } else {
                    Text(m.texto)
                        .padding(.top, 3)
                        .textSelection(.enabled)
                }
                Spacer(minLength: 20)
            }
        }
    }
}

// MARK: - Bienvenida

struct SplashView: View {
    @State private var aparece = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.12),
                         Color(red: 0.14, green: 0.06, blue: 0.28)],
                startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Orbe(tam: 140)
                    .scaleEffect(aparece ? 1 : 0.3)
                    .opacity(aparece ? 1 : 0)
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: aparece)

                Text("Alexa IA")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(aparece ? 1 : 0)
                    .offset(y: aparece ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: aparece)

                Text("Tu inteligencia personal,\n100% en tu iPhone")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(aparece ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.9), value: aparece)

                Text("Creada por @soyadrianyt001")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(aparece ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(1.4), value: aparece)
            }
            .padding()
        }
        .onAppear { aparece = true }
    }
}

// MARK: - Términos

struct TerminosView: View {
    var aceptar: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Términos y condiciones")
                        .font(.title.bold())
                    Text("Última actualización: noviembre de 2026")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    ForEach(Terminos.secciones, id: \.0) { s in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.0).font(.headline)
                            Text(s.1).foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            if let aceptar = aceptar {
                Button {
                    aceptar()
                } label: {
                    Text("Aceptar y continuar")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary)
                        .foregroundColor(Color(.systemBackground))
                        .clipShape(Capsule())
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Chat

struct ChatView: View {
    @EnvironmentObject var cerebro: Cerebro
    @State private var texto = ""
    @State private var ajustes = false

    private let sugerencias: [(String, String)] = [
        ("face.smiling", "Cuéntame un chiste"),
        ("function", "¿Cuánto es 25 por 4?"),
        ("brain.head.profile", "Dame un pensamiento"),
        ("heart", "Estoy triste"),
        ("clock", "¿Qué hora es?"),
        ("lightbulb", "Dato curioso")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if cerebro.mensajes.isEmpty {
                    bienvenida
                } else {
                    lista
                }
                barraEntrada
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { ajustes = true } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .principal) {
                    selector
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { cerebro.nuevaConversacion() } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $ajustes) {
                AjustesView()
                    .environmentObject(cerebro)
            }
        }
    }

    var selector: some View {
        Menu {
            Picker("Modelo", selection: $cerebro.modo) {
                ForEach(Modo.allCases) { m in
                    Label("\(m.nombre) · \(m.detalle)", systemImage: m.icono)
                        .tag(m)
                }
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Text("Alexa IA").font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                }
                Text(cerebro.modo.nombre)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.primary)
        }
    }

    var bienvenida: some View {
        ScrollView {
            VStack(spacing: 18) {
                Spacer(minLength: 40)
                Orbe(tam: 84)
                Text(cerebro.nombre.isEmpty ? "¿En qué te ayudo hoy?" : "Hola, \(cerebro.nombre) 👋")
                    .font(.title2.bold())
                Text("Pregúntame, charlemos o cuéntame cómo te sientes.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(sugerencias, id: \.1) { s in
                        Button {
                            cerebro.enviar(s.1)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: s.0)
                                Text(s.1)
                                    .font(.subheadline)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
    }

    var lista: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(cerebro.mensajes) { m in
                        FilaMensaje(m: m).id(m.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: cerebro.mensajes.count) { _ in bajar(proxy) }
            .onChange(of: cerebro.mensajes.last?.texto) { _ in bajar(proxy) }
        }
    }

    var barraEntrada: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Escribe un mensaje…", text: $texto, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            Button {
                let t = texto
                texto = ""
                cerebro.enviar(t)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.systemBackground))
                    .frame(width: 36, height: 36)
                    .background(vacio ? Color.gray.opacity(0.4) : Color.primary)
                    .clipShape(Circle())
            }
            .disabled(vacio)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    var vacio: Bool {
        texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func bajar(_ proxy: ScrollViewProxy) {
        if let u = cerebro.mensajes.last {
            withAnimation { proxy.scrollTo(u.id, anchor: .bottom) }
        }
    }
}

// MARK: - Enseñar

struct EnsenarView: View {
    @EnvironmentObject var cerebro: Cerebro
    @State private var p = ""
    @State private var r = ""

    var body: some View {
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
            Section("Conocimiento integrado") {
                Text("\(Conocimiento.base.count) respuestas de fábrica dentro de la app")
                    .foregroundColor(.secondary)
            }
            Section("Lo que me enseñaste (\(cerebro.saberes.count))") {
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

// MARK: - Ajustes

struct AjustesView: View {
    @EnvironmentObject var cerebro: Cerebro
    @Environment(\.dismiss) private var cerrar
    @State private var exportando = false
    @State private var importando = false
    @State private var docu = RespaldoDoc(datos: Data())
    @State private var aviso = ""
    @State private var mostrarAviso = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        EnsenarView()
                    } label: {
                        Label("Enseñar a Alexa IA", systemImage: "graduationcap")
                    }
                    NavigationLink {
                        TerminosView()
                    } label: {
                        Label("Términos y condiciones", systemImage: "doc.text")
                    }
                }
                Section("Respaldo") {
                    Button {
                        docu = RespaldoDoc(datos: cerebro.datosRespaldo() ?? Data())
                        exportando = true
                    } label: {
                        Label("Exportar respaldo", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        importando = true
                    } label: {
                        Label("Importar respaldo", systemImage: "square.and.arrow.down")
                    }
                }
                Section("Conversación") {
                    Button(role: .destructive) {
                        cerebro.nuevaConversacion()
                        cerrar()
                    } label: {
                        Label("Borrar conversación", systemImage: "trash")
                    }
                }
                Section("Acerca de") {
                    HStack {
                        Text("Creador")
                        Spacer()
                        Text("@soyadrianyt001").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("2.0").foregroundColor(.secondary)
                    }
                    Text("100% local: sin internet ni servidores.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") { cerrar() }
                }
            }
            .fileExporter(isPresented: $exportando,
                          document: docu,
                          contentType: .json,
                          defaultFilename: "AlexaIA-respaldo") { _ in }
            .fileImporter(isPresented: $importando,
                          allowedContentTypes: [.json]) { resultado in
                if case .success(let url) = resultado {
                    let acceso = url.startAccessingSecurityScopedResource()
                    defer { if acceso { url.stopAccessingSecurityScopedResource() } }
                    if let d = try? Data(contentsOf: url), cerebro.restaurar(d) {
                        aviso = "Respaldo restaurado."
                    } else {
                        aviso = "No se pudo leer ese archivo."
                    }
                    mostrarAviso = true
                }
            }
            .alert(aviso, isPresented: $mostrarAviso) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

// MARK: - Raíz de la app

struct Raiz: View {
    @AppStorage("terminosAceptados") private var aceptados = false
    @State private var mostrandoSplash = true

    var body: some View {
        ZStack {
            if mostrandoSplash {
                SplashView()
                    .transition(.opacity)
            } else if !aceptados {
                TerminosView {
                    withAnimation { aceptados = true }
                }
                .transition(.opacity)
            } else {
                ChatView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            withAnimation(.easeInOut(duration: 0.6)) {
                mostrandoSplash = false
            }
        }
    }
}

@main
struct AlexaIAApp: App {
    @StateObject private var cerebro = Cerebro()

    var body: some Scene {
        WindowGroup {
            Raiz()
                .environmentObject(cerebro)
        }
    }
}
