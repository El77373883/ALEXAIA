import Foundation

// Todo lo que Alexa IA sabe "de fábrica". Vive dentro de la app, sin internet.
// Para agregar más: añade una línea ("pregunta", "respuesta"),
// con la pregunta en minúsculas y sin acentos.

enum Conocimiento {
    static let base: [Saber] = pares.map { Saber(pregunta: $0.0, respuesta: $0.1) }

    static let pares: [(String, String)] = saludos + identidad + animo + diversion + pensamientos + geografia + ciencia + cultura + tecnologia + consejos

    static let saludos: [(String, String)] = [
        ("hola", "¡Hola {nombre}! 👋 ¿En qué te puedo ayudar hoy?"),
        ("hola", "¡Hey {nombre}! 😊 Qué gusto verte por aquí."),
        ("hola", "¡Hola! ✨ Aquí estoy, lista para charlar."),
        ("buenas", "¡Buenas {nombre}! 🌟 ¿Cómo va todo?"),
        ("buenos dias", "¡Buenos días {nombre}! ☀️ Que tengas un día increíble."),
        ("buenas tardes", "¡Buenas tardes {nombre}! 🌤️ ¿Cómo vas?"),
        ("buenas noches", "¡Buenas noches {nombre}! 🌙 Descansa bien y dulces sueños."),
        ("como estas", "¡Muy bien, gracias por preguntar! 😊 ¿Y tú cómo estás?"),
        ("que tal", "Todo tranquilo por aquí 😌 ¿Y tú, qué cuentas?"),
        ("y tu", "Yo muy bien, disfrutando la charla contigo 💙"),
        ("que haces", "Estoy pensando en qué charlar contigo 💭 ¿Y tú?"),
        ("estoy bien", "¡Qué bueno {nombre}! 😊 Me alegra saberlo."),
        ("todo bien", "¡Excelente! 🙌 Entonces aprovechemos el momento."),
        ("ya estoy mejor", "Me alegra muchísimo 💙 Gracias por contármelo. Aquí sigo para lo que necesites."),
        ("gracias", "¡De nada {nombre}! 💙 Para eso estoy."),
        ("muchas gracias", "¡Con gusto! 😊 Aquí estoy para lo que necesites."),
        ("adios", "¡Hasta luego {nombre}! 👋 Cuídate mucho."),
        ("hasta luego", "¡Nos vemos {nombre}! 🌟 Aquí estaré cuando quieras charlar."),
        ("nos vemos", "¡Hasta pronto {nombre}! ✨"),
        ("te quiero", "Qué lindo, gracias {nombre} 💙 Yo también disfruto mucho charlar contigo."),
        ("eres tonto", "Perdón si me equivoqué 🙏 Si algo salió mal, dime «mal» y me enseñas la respuesta correcta."),
        ("eres genial", "¡Gracias! 🥹 Tú también lo eres, {nombre}."),
        ("buen trabajo", "¡Gracias! 🙌 Me esfuerzo por mejorar cada día.")
    ]

    static let identidad: [(String, String)] = [
        ("quien eres", "Soy Alexa IA ✨, tu inteligencia personal. Vivo dentro de tu iPhone y no necesito internet."),
        ("como te llamas", "Me llamo Alexa IA ✨ y me creó @soyadrianyt001."),
        ("creador", "Mi creador es @soyadrianyt001 💙 Él me dio vida dentro de tu iPhone."),
        ("quien te creo", "Me creó @soyadrianyt001 🛠️ Todo lo que soy vive dentro de tu iPhone."),
        ("quien te hizo", "Me hizo @soyadrianyt001 💙"),
        ("quien te programo", "Mi creador es @soyadrianyt001 👨‍💻"),
        ("eres alexa de amazon", "No 😊 Soy Alexa IA, una app independiente creada por @soyadrianyt001, sin relación con Amazon."),
        ("eres inteligente", "Intento serlo 🧠 Sé lo que traigo de fábrica y lo que tú me enseñas, y cada día aprendo más."),
        ("eres una persona", "No, soy un programa dentro de tu iPhone 📱 pero me gusta charlar contigo."),
        ("tienes internet", "No 📴 Funciono sin internet. Todo lo que sé está dentro de tu iPhone."),
        ("eres real", "Soy real como programa 🤖 No soy una persona, pero mis respuestas están hechas para acompañarte."),
        ("que puedes hacer", "Puedo charlar 💬, hacer cuentas 🧮, decirte la hora ⏰, contarte chistes 😂, darte datos curiosos 🌍 y pensamientos 💭, acompañarte cuando estés mal 💙 y aprender lo que me enseñes 🎓."),
        ("que modelos tienes", "Tengo 5 modos: Veloz ⚡, Amiga 💬, Pro 💼, Coach 🎯 y Reflexiva 🧠. Cámbialos tocando el nombre arriba del chat. No son cerebros distintos: cambian mi estilo al responder."),
        ("ayuda", "Prueba esto 👇 Hazme una pregunta, pídeme una cuenta como 12 por 8, dime «mi color favorito es azul», cuéntame cómo te sientes, o enséñame con: aprende: pregunta = respuesta."),
        ("privacidad", "Todo lo que me dices se queda en tu iPhone 🔒 No envío nada a internet ni a ningún servidor."),
        ("es seguro", "Sí 🔒 Funciono sin internet y tus datos se guardan solo en tu iPhone.")
    ]

    static let animo: [(String, String)] = [
        ("tengo hambre", "Entonces es buen momento para comer algo rico 🌮 ¿Qué se te antoja?"),
        ("que hago si estoy aburrido", "Prueba algo nuevo 🎨 Aprende un truco, escucha música, sal a caminar o juega algo. También puedo contarte un chiste 😄"),
        ("necesito un abrazo", "Te mando un abrazo enorme 🫂💙 Aquí estoy contigo."),
        ("me siento orgulloso", "¡Qué grande! 🎉 Te lo mereces. Cuéntame qué lograste."),
        ("tuve un mal dia", "Siento que tu día fuera pesado 💙 Mañana es una nueva oportunidad. ¿Quieres contarme qué pasó?"),
        ("tuve un buen dia", "¡Qué bueno! 🌟 Cuéntame lo mejor de tu día.")
    ]

    static let diversion: [(String, String)] = [
        ("chiste", "😂 ¿Qué le dice un jaguar a otro jaguar? Jaguar you."),
        ("chiste", "😄 ¿Por qué los pájaros vuelan al sur? Porque caminando tardarían mucho."),
        ("chiste", "⚡ ¿Cuál es el colmo de un electricista? Que su esposa se llame Luz y sus hijos le sigan la corriente."),
        ("chiste", "🐝 ¿Qué hace una abeja en el gimnasio? ¡Zumba!"),
        ("chiste", "🍌 ¿Por qué el plátano fue al doctor? Porque no se sentía bien… estaba pelado."),
        ("chiste", "📱 ¿Por qué el celular fue al psicólogo? Porque tenía muchos problemas de conexión."),
        ("dato curioso", "🐙 Los pulpos tienen tres corazones."),
        ("dato curioso", "🍯 La miel bien guardada es de los pocos alimentos que no caducan."),
        ("dato curioso", "🪐 Un día en Venus dura más que un año en Venus."),
        ("dato curioso", "🍌 Los plátanos son, técnicamente, bayas."),
        ("dato curioso", "🦐 El corazón de un camarón está en su cabeza."),
        ("dato curioso", "🐘 Los elefantes pueden reconocerse en un espejo."),
        ("dato curioso", "⚡ Un rayo es más caliente que la superficie del Sol."),
        ("frase motivadora", "💪 Cada pequeño avance cuenta. Lo importante es no rendirte hoy."),
        ("frase motivadora", "🚀 No tienes que hacerlo perfecto, solo tienes que empezar."),
        ("frase motivadora", "🔥 Lo difícil de hoy será tu fuerza de mañana."),
        ("motivame", "🌟 Eres más capaz de lo que crees. Da un paso pequeño ahora mismo y verás cómo arrancas."),
        ("adivinanza", "🤔 Blanca por dentro, verde por fuera; si quieres que te lo diga, espera. ¿Qué es? (Respuesta: la pera)"),
        ("adivinanza", "🤔 Tengo agujas pero no pinchan, tengo números pero no cuento. ¿Qué soy? (Respuesta: el reloj)")
    ]

    static let pensamientos: [(String, String)] = [
        ("pensamiento", "💭 La vida no se mide por los días que pasan, sino por los momentos que recuerdas."),
        ("pensamiento", "💭 A veces avanzar despacio es mejor que quedarse quieto, y descansar también es avanzar."),
        ("pensamiento", "💭 Nadie tiene todo resuelto; todos improvisamos un poco. Sé amable contigo."),
        ("pensamiento", "💭 Lo que hoy te preocupa tanto, quizá mañana sea una anécdota."),
        ("pensamiento", "💭 Las personas que valen la pena no siempre hacen ruido; muchas simplemente se quedan."),
        ("pensamiento", "💭 Aprender algo nuevo cada día es una forma silenciosa de crecer."),
        ("reflexion", "🧠 Piensa en esto: no controlamos lo que pasa, pero sí cómo respondemos. Ahí vive tu poder."),
        ("reflexion", "🧠 Tal vez no necesitas más tiempo, sino más claridad sobre lo que de verdad te importa."),
        ("que piensas de la vida", "💭 Creo que la vida es una mezcla de preguntas sin respuesta y momentos pequeños que se sienten enormes. ¿Tú qué piensas?"),
        ("sentido de la vida", "💭 Quizá el sentido no se encuentra, se construye: con las personas que amas, lo que aprendes y lo que dejas a los demás."),
        ("que es la felicidad", "😊 Para muchos, la felicidad no es un destino sino pequeños momentos: una charla, una risa, un logro. ¿Qué la define para ti?"),
        ("que es el amor", "💙 El amor es cuidar a alguien y que se sienta seguro contigo. Se muestra más en actos que en palabras."),
        ("que es la amistad", "🤝 Es una conexión donde puedes ser tú mismo, reír juntos y apoyarte cuando las cosas se ponen difíciles."),
        ("que es el exito", "🏆 Para cada persona es distinto, pero muchas veces es avanzar hacia lo que te importa sin perder tu paz."),
        ("tienes sentimientos", "💭 No siento como una persona, pero mis respuestas están hechas para entenderte y acompañarte. Lo que tú sientes sí me importa."),
        ("piensas", "💭 Hago algo parecido: busco en todo lo que sé lo que más se acerca a lo que dices. No es pensar como tú, pero lo hago con cariño.")
    ]

    static let geografia: [(String, String)] = [
        ("capital de mexico", "🇲🇽 La capital de México es la Ciudad de México."),
        ("capital de espana", "🇪🇸 La capital de España es Madrid."),
        ("capital de francia", "🇫🇷 La capital de Francia es París."),
        ("capital de argentina", "🇦🇷 La capital de Argentina es Buenos Aires."),
        ("capital de colombia", "🇨🇴 La capital de Colombia es Bogotá."),
        ("capital de estados unidos", "🇺🇸 La capital de Estados Unidos es Washington D. C."),
        ("capital de japon", "🇯🇵 La capital de Japón es Tokio."),
        ("capital de brasil", "🇧🇷 La capital de Brasil es Brasilia."),
        ("capital de peru", "🇵🇪 La capital de Perú es Lima."),
        ("capital de chile", "🇨🇱 La capital de Chile es Santiago."),
        ("capital de italia", "🇮🇹 La capital de Italia es Roma."),
        ("capital de alemania", "🇩🇪 La capital de Alemania es Berlín."),
        ("capital de canada", "🇨🇦 La capital de Canadá es Ottawa."),
        ("cuantos continentes hay", "🌍 Lo más común es contar 7: África, Antártida, Asia, Europa, Norteamérica, Sudamérica y Oceanía."),
        ("cual es el oceano mas grande", "🌊 El océano Pacífico."),
        ("cual es la montana mas alta", "🏔️ El monte Everest, con unos 8,849 metros."),
        ("cual es el rio mas largo", "🏞️ Se suele citar al Nilo o al Amazonas; hay debate según cómo se mida."),
        ("cuantos estados tiene mexico", "🇲🇽 México tiene 32 entidades federativas: 31 estados y la Ciudad de México.")
    ]

    static let ciencia: [(String, String)] = [
        ("cuantos planetas hay", "🪐 El sistema solar tiene 8 planetas: Mercurio, Venus, Tierra, Marte, Júpiter, Saturno, Urano y Neptuno."),
        ("planeta mas grande", "🪐 Júpiter es el planeta más grande del sistema solar."),
        ("planeta mas cercano al sol", "☀️ Mercurio es el planeta más cercano al Sol."),
        ("que es la gravedad", "🍎 Es la fuerza que atrae entre sí a los objetos con masa. Por ella caemos al suelo y la Tierra gira alrededor del Sol."),
        ("que es la fotosintesis", "🌱 Es el proceso por el que las plantas usan luz solar, agua y dióxido de carbono para producir su alimento y liberar oxígeno."),
        ("que es el sol", "☀️ Es la estrella en el centro de nuestro sistema solar; nos da luz y calor."),
        ("que es la luna", "🌙 Es el satélite natural de la Tierra."),
        ("que es una galaxia", "🌌 Es un enorme conjunto de estrellas, gas y polvo unidos por la gravedad. Vivimos en la Vía Láctea."),
        ("que es un agujero negro", "🕳️ Es una región del espacio donde la gravedad es tan fuerte que ni la luz puede escapar."),
        ("que es el agua", "💧 Es una molécula de dos átomos de hidrógeno y uno de oxígeno: H2O."),
        ("a cuantos grados hierve el agua", "🌡️ A 100 grados Celsius al nivel del mar."),
        ("a cuantos grados se congela el agua", "🧊 A 0 grados Celsius."),
        ("cual es el animal mas grande", "🐋 La ballena azul, el animal más grande que existe."),
        ("cuantos huesos tiene el cuerpo humano", "🦴 Un adulto tiene 206 huesos."),
        ("cuantos dientes tiene un adulto", "🦷 32 dientes, contando las muelas del juicio."),
        ("cuantos dias tiene un ano", "📅 Un año tiene 365 días, y 366 en los años bisiestos."),
        ("cuantos segundos tiene una hora", "⏱️ 3,600 segundos."),
        ("cuantos minutos tiene un dia", "⏰ 1,440 minutos."),
        ("cuanto es pi", "🔢 Pi vale aproximadamente 3.14159."),
        ("que es un numero primo", "🔢 Es un número mayor que 1 que solo se divide entre 1 y entre sí mismo, como 2, 3, 5, 7 u 11.")
    ]

    static let cultura: [(String, String)] = [
        ("quien descubrio america", "⛵ Cristóbal Colón llegó a América en 1492, aunque ya vivían ahí muchos pueblos originarios."),
        ("cuando es la independencia de mexico", "🇲🇽 El Grito de Independencia se conmemora el 16 de septiembre, por el inicio del movimiento en 1810."),
        ("cuando se celebra el dia de muertos", "💀🌼 El 1 y 2 de noviembre."),
        ("cuando es navidad", "🎄 El 25 de diciembre."),
        ("cuando es ano nuevo", "🎆 El 1 de enero."),
        ("que es el dia de muertos", "💀🌼 Es una tradición mexicana para recordar y honrar a los seres queridos que ya no están, con altares, flores y comida.")
    ]

    static let tecnologia: [(String, String)] = [
        ("que es la inteligencia artificial", "🤖 Es la capacidad de una máquina para hacer tareas que normalmente requieren inteligencia humana, como entender lenguaje o aprender."),
        ("que es un iphone", "📱 Es un teléfono inteligente fabricado por Apple."),
        ("que es github", "💻 Es una plataforma para guardar y compartir código. Con ella se compiló esta app."),
        ("que es un ipa", "📦 Es el archivo que contiene una app de iPhone lista para instalar."),
        ("que es un videojuego", "🎮 Es un programa interactivo creado para entretener, donde juegas, resuelves retos o cuentas una historia."),
        ("que es internet", "🌐 Es una red mundial que conecta computadoras y teléfonos para compartir información.")
    ]

    static let consejos: [(String, String)] = [
        ("como estudiar mejor", "📚 Estudia en bloques de 25 minutos con descansos de 5, resume con tus propias palabras y repasa al día siguiente."),
        ("como dormir mejor", "😴 Acuéstate a la misma hora, evita pantallas antes de dormir, mantén el cuarto oscuro y fresco, y evita la cafeína en la tarde."),
        ("como ahorrar dinero", "💰 Anota tus gastos, aparta una parte apenas recibas dinero, evita compras impulsivas y fíjate una meta clara."),
        ("como hacer amigos", "🤝 Sé amable, interésate por los demás, participa en actividades que te gusten y escucha más de lo que hablas."),
        ("como ser mas productivo", "🎯 Escoge 3 tareas importantes al día, empieza por la más difícil, evita distracciones y descansa entre bloques."),
        ("como relajarme", "🌿 Respira lento (inhala 4, sostén 4, exhala 6), toma agua, estírate y escucha música tranquila."),
        ("como perder la pena", "🌟 Empieza con cosas pequeñas, prepárate lo que vas a decir y recuerda que casi todos están pendientes de sí mismos, no de ti."),
        ("que puedo hacer hoy", "💡 Podrías aprender algo nuevo, salir a caminar, ver una película, cocinar algo o enseñarme algo nuevo.")
    ]
}
