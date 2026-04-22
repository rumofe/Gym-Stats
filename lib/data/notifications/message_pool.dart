import '../../core/constants/app_constants.dart';

/// Returns the message list for [reminderType] + [personality].
/// Falls back gracefully for unmapped combinations.
class MessagePool {
  MessagePool._();

  static List<String> get(String reminderType, String personality) {
    final pool = _pool[reminderType]?[personality] ??
        _pool[AppConstants.reminderMotivational]?[personality] ??
        _fallback;
    return List.unmodifiable(pool);
  }

  static List<String> getFiltered(
    String reminderType,
    String personality,
    List<String> blacklist,
  ) {
    final all = get(reminderType, personality);
    final filtered = all.where((m) => !blacklist.contains(m)).toList();
    return filtered.isEmpty ? all : filtered;
  }

  static const List<String> _fallback = [
    'Es hora de entrenar. ¡Vamos!',
    'Tu cuerpo te lo agradecerá.',
  ];

  static const Map<String, Map<String, List<String>>> _pool = {
    // ── GYM ───────────────────────────────────────────────────────────────────
    AppConstants.reminderGym: {
      AppConstants.personalityEpic: [
        '¡LA HORA DE LA BATALLA HA LLEGADO! Las barras te esperan, guerrero.',
        '¡HOY FORJAS LA LEYENDA! Cada rep es un ladrillo en tu templo.',
        '¡EL HIERRO LLAMA! Responde con todo lo que tienes.',
        '¡MÚSCULOS O EXCUSAS! Los campeones eligieron hace rato.',
        '¡TU VERSIÓN MÁS FUERTE está a una sesión de distancia!',
        '¡ÉPICO o NADA! Hoy no hay término medio en el gym.',
        '¡LOS GRANDES no esperan motivación, la crean! Hora de entrenar.',
      ],
      AppConstants.personalitySarcastic: [
        'Sorpresa: el gym no va a ir a tu casa. Toca moverse.',
        'El sofá ya sabe tu forma perfectamente. El gym todavía no.',
        'Tus músculos están esperando. Llevan tiempo esperando, la verdad.',
        'No te preocupes, las mancuernas no se van a usar solas… o sí.',
        'Hoy toca gym. Puedes ignorarme, pero la barra seguirá ahí mañana.',
        '¿Sabías que el entrenamiento requiere estar EN el gym? Dato curioso.',
        'Tu yo del futuro te lo va a agradecer. O a odiar. Tú decides.',
      ],
      AppConstants.personalityMotivational: [
        'Cada entrenamiento te acerca a quien quieres ser. ¡Hoy es el día!',
        'El progreso no pide permiso. ¡Sal y consíguelo!',
        'No entrenas para parecer diferente. Entrenas para SERLO.',
        'Una sesión más, una versión mejor de ti. ¡Vamos!',
        'Los resultados llegan cuando la constancia manda. ¡Tú puedes!',
        'Hoy será un gran día de entrenamiento. ¡Lo siento en el ambiente!',
        'La disciplina te lleva donde la motivación no alcanza. ¡Adelante!',
      ],
      AppConstants.personalityFriendly: [
        '¡Hey! Es hora del gym. ¿Lista/o para darlo todo hoy? 💪',
        'Toca entrenar. ¡Recuerda lo bien que te sientes después!',
        '¡El gym te espera! Vístete, que hoy va a ser genial.',
        'Oye, no olvides tu sesión. ¡Ya verás lo bien que queda!',
        '¡Hola! Momento gym. Tú puedes, ya lo has hecho antes.',
        'Es tu hora favorita (aunque ahora mismo no lo parezca 😄). ¡Gym!',
        '¡Ánimo! Una vez que empieces no querrás parar.',
      ],
      AppConstants.personalityMilitary: [
        '¡SOLDADO, HORA DE ENTRENAMIENTO! No hay excusas válidas.',
        '¡EN PIE! El gym no espera a nadie. Muévete AHORA.',
        '¡FOCO! Un guerrero no falta a su entrenamiento diario.',
        '¡DISCIPLINA es hacer lo que toca aunque no apetezca! Al gym.',
        '¡MISIÓN: GYM! Objetivo: completar la sesión. Sin excusas.',
        '¡UN MARINE nunca abandona su rutina! Es tu hora. VAMOS.',
        '¡ATENCIÓN! Entrenamiento en curso. Preséntate en 10 minutos.',
      ],
    },

    // ── CARDIO ────────────────────────────────────────────────────────────────
    AppConstants.reminderCardio: {
      AppConstants.personalityEpic: [
        '¡HORA DE CORRER HACIA TU MEJOR VERSIÓN! Las zapatillas, guerrero.',
        '¡EL CORAZÓN DE UN CAMPEÓN late más fuerte con cada zancada!',
        '¡CARDIO ÉPICO HOY! Tu zona 2 te está reclamando.',
        '¡DESAFÍA TUS LÍMITES cardiovasculares! Hoy rompemos marcas.',
        '¡LOS PULMONES SE FORJAN en el asfalto y la cinta! Sal a correr.',
      ],
      AppConstants.personalitySarcastic: [
        'El cardio sigue siendo bueno para la salud. Por si no lo sabías.',
        'Tus pulmones dijeron que les gustaría trabajar hoy. Qué caprichosos.',
        'El plan de cardio no se completa solo. Spoiler: requiere que vayas.',
        'Hoy toca cardio. No, no puedes sustituirlo con pensarlo intensamente.',
        'Tus zapatillas llevan días mirándote con cara de decepción.',
      ],
      AppConstants.personalityMotivational: [
        '¡Cada paso te hace más fuerte! Es hora de tu cardio.',
        'Tu corazón se vuelve más eficiente con cada sesión. ¡Adelante!',
        '¡Hoy es día de cardio! El mejor seguro de vida que existe.',
        'Zona 2 activa: quema grasa, cuida el corazón. ¡Vamos a ello!',
        '¡El cardio de hoy es la energía de mañana! No te lo saltes.',
      ],
      AppConstants.personalityFriendly: [
        '¡Hey! Toca cardio hoy. ¿Caminata, trote o algo más intenso? 🏃',
        'Recuerda tu sesión de cardio. ¡Te sentirás genial después!',
        '¡Hola! Es hora de mover las piernas. Sal a disfrutar.',
        '¡Cardio time! Ponle los auriculares y disfruta del ritmo.',
        'Pequeño recordatorio: tu sesión de cardio. ¡Tú puedes!',
      ],
      AppConstants.personalityMilitary: [
        '¡SOLDADO, CARDIO OBLIGATORIO! El corazón se entrena o se debilita.',
        '¡MOVIMIENTO ES VIDA! Sal a correr. AHORA. Sin excusas.',
        '¡RESISTENCIA CARDIOVASCULAR es la base del combatiente! Entrena.',
        '¡MISIÓN CARDIO! Completar la sesión del plan. Sin abandonar.',
        '¡UN EJÉRCITO marcha. Tú también. Zapatillas. VAMOS.',
      ],
    },

    // ── PESO CORPORAL ─────────────────────────────────────────────────────────
    AppConstants.reminderWeigh: {
      AppConstants.personalityEpic: [
        '¡HORA DE RENDIR CUENTAS AL MARCADOR! La báscula te espera, campeón.',
        '¡LOS DATOS SON PODER! Regístra tu peso y domina tu progreso.',
        '¡EL CAMPEÓN MIDE su avance! Báscula, ahora.',
      ],
      AppConstants.personalitySarcastic: [
        'La báscula sigue en el mismo sitio. Solo digo.',
        'Tu peso de hoy no se va a registrar solo. Misteriosamente.',
        'Pesarte lleva 30 segundos. Tus excusas llevan más. Báscula, ya.',
      ],
      AppConstants.personalityMotivational: [
        '¡Registrar tu peso es medir tu progreso! Hoy es el día.',
        'Los datos honestos son la base del cambio. ¡A la báscula!',
        'Sin miedo al número. Es solo información que te ayuda a crecer.',
      ],
      AppConstants.personalityFriendly: [
        '¡Buenos días! Momento de pesarte antes de desayunar. 😊',
        'Pequeño recordatorio: báscula hoy. ¡Sin presión, solo datos!',
        'Oye, ¿te has pesado ya? Primer momento del día es el mejor.',
      ],
      AppConstants.personalityMilitary: [
        '¡INFORME DE PESO! Regístralo ahora. Los datos no se retrasan.',
        '¡CONTROL DE AVANCE! Báscula. Ya. Sin demoras.',
        '¡MISIÓN BÁSCULA! Monitorizar el progreso es parte del protocolo.',
      ],
    },

    // ── MOTIVACIONAL ──────────────────────────────────────────────────────────
    AppConstants.reminderMotivational: {
      AppConstants.personalityEpic: [
        '¡TU POTENCIAL no tiene límites que tú no le pongas! ¡ROMPE HOY!',
        '¡CADA DÍA que te rindes, el campeón que podrías ser llora! ¡LEVÁNTATE!',
        '¡LA GRANDEZA está reservada para quienes no conocen la rendición!',
        '¡HOY puede ser el día que lo cambie todo! ¿Vas a desperdiciarlo?',
        '¡ERES MÁS FUERTE de lo que crees y más cerca de lo que piensas!',
      ],
      AppConstants.personalitySarcastic: [
        'Otro día, otra oportunidad de ser mejor que ayer. O no. Tú eliges.',
        'El universo no te debe nada. Pero tú a ti mismo sí. Reflexiona.',
        'La motivación es sobrevalorada. La disciplina nunca. Ponte.',
        'El éxito es un poco incómodo. Menos que el arrepentimiento, eso sí.',
        'Nadie va a venir a salvarte. Buenas noticias: tampoco lo necesitas.',
      ],
      AppConstants.personalityMotivational: [
        '¡Eres capaz de más de lo que imaginas! Hoy demuéstratelo.',
        'El único límite real eres tú mismo. Y hoy, ese límite retrocede.',
        '¡Pequeños pasos cada día crean grandes cambios! Sigue adelante.',
        'Tu esfuerzo de hoy es la recompensa de mañana. ¡No pares!',
        '¡Cree en el proceso! Cada día cuenta, aunque no lo parezca.',
        '¡El progreso existe incluso cuando no lo ves! Confía y sigue.',
      ],
      AppConstants.personalityFriendly: [
        '¡Hola! Solo quería recordarte que lo estás haciendo genial. 😊',
        'Oye, un día a la vez. Pequeños pasos, grandes cambios. ¡Ánimo!',
        '¿Sabes qué? Hoy puede ser un día increíble. ¡Tú puedes con ello!',
        'Solo un recordatorio amistoso: eres más capaz de lo que crees.',
        '¡Buenos días! Hoy también eres suficiente. ¡A por ello!',
        '¡Hey! El mejor momento para empezar era antes. El segundo, ahora.',
      ],
      AppConstants.personalityMilitary: [
        '¡SOLDADO! La queja es para los débiles. ¡ACTÚA y MEJORA!',
        '¡DISCIPLINA MENTAL primero! Tu cuerpo sigue a tu mente. ¡FOCO!',
        '¡SIN EXCUSAS! Los resultados llegan con trabajo, no con lamentos.',
        '¡LA BATALLA más importante es la que se libra en tu cabeza! ¡GANA!',
        '¡FORTALEZA no es ausencia de miedo. Es actuar a pesar de él! VAMOS.',
      ],
    },
  };
}
