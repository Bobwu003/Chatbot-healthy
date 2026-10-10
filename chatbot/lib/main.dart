import 'package:flutter/material.dart';

void main() {
  runApp(const NutriApp());
}

const Color fondo = Color(0xFFFCFBFF);
const Color verdeClaro = Color(0xFFE6F0D5);
const Color verde = Color(0xFF7FA86B);
const Color amarillo = Color(0xFFFFF3D6);
const Color naranja = Color(0xFFFDC67F);
const Color textoOscuro = Color(0xFF393344);

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutri - Asistente de Nutrición',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: fondo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: verde,
          primary: verde,
          surface: fondo,
        ),
        fontFamily: 'Roboto',
      ),
      home: const NutriChatPage(),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}

class NutriChatPage extends StatefulWidget {
  const NutriChatPage({super.key});

  @override
  State<NutriChatPage> createState() => _NutriChatPageState();
}

class _NutriChatPageState extends State<NutriChatPage> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  bool isTyping = false;

  final List<ChatMessage> messages = [
    ChatMessage(
      text: '¡Hola! Soy Nutri, tu asistente de nutrición. '
          'Puedo ayudarte con dudas sobre alimentación, ideas de '
          'comidas, hidratación y hábitos saludables. '
          '¿Sobre qué te gustaría saber?',
      isUser: false,
    ),
  ];

  final List<String> quickOptions = [
    '¿Cuánta agua debo tomar?',
    'Ideas de desayuno',
    '¿Cuántas calorías necesito?',
    'Alimentos con proteína',
    '¿Cómo bajar de peso?',
    'Snacks saludables',
    ' Azucar en sangre en niños',
    ' Azucar en sangre en un adulto ',
    ' Azucar en sangre en un adulta ',
  ];

  void sendMessage([String? predefinedText]) {
    final text = (predefinedText ?? messageController.text).trim();

    if (text.isEmpty || isTyping) return;

    messageController.clear();

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      isTyping = true;
    });

    scrollToBottom();

    final response = getNutriResponse(text);

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;

      setState(() {
        messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        isTyping = false;
      });

      scrollToBottom();
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String getNutriResponse(String input) {
    final text = input.toLowerCase();

    bool esSangre = _containsAny(text, [
      'sangre',
      'glucosa',
      'nivel',
      'niveles',
      'rango',
    ]);
    bool esAzucar = _containsAny(text, [
      'azucar',
      'azúcar',
    ]);

    if ((esSangre && esAzucar) || text.contains('glucosa')) {
      if (_containsAny(text, [
        'niño',
        'niña',
        'niños',
        'niñas',
        'joven',
        'infantil',
        'adolescente',
      ])) {
        return 'Para los niños y niñas, los niveles normales de '
            'azúcar en sangre (glucosa) en ayunas deben estar entre '
            '70 y 100 mg/dL. Dos horas después de comer, deben ser '
            'menores a 140 mg/dL. Si hay antecedentes de diabetes '
            'en la familia, es importante revisar los niveles '
            'periódicamente con un pediatra.';
      } else if (_containsAny(text, [
        'mujer',
        'mujeres',
        'adulta',
        'embarazo',
      ])) {
        return 'Para las mujeres adultas, los niveles normales de '
            'azúcar en sangre (glucosa) en ayunas suelen estar entre '
            '70 y 99 mg/dL. Dos horas después de comer, deben ser '
            'menores a 140 mg/dL. Si estás embarazada, los rangos '
            'son más estrictos: en ayunas debe ser menor a 95 mg/dL. '
            'Estos valores son orientativos; siempre consulta a un '
            'médico.';
      } else if (_containsAny(text, [
        'hombre',
        'hombres',
        'adulto',
      ])) {
        return 'Para los hombres adultos, los niveles normales de '
            'azúcar en sangre (glucosa) en ayunas deben estar entre '
            '70 y 99 mg/dL. Dos horas después de comer, deben ser '
            'menores a 140 mg/dL. Niveles entre 100 y 125 mg/dL en '
            'ayunas pueden indicar prediabetes. Consulta a un médico '
            'para una evaluación completa.';
      } else {
        return 'El rango normal de azúcar en sangre (glucosa) en '
            'ayunas es de 70 a 99 mg/dL. Dos horas después de comer, '
            'debe ser menor a 140 mg/dL. Niveles de 100 a 125 mg/dL '
            'en ayunas indican prediabetes, y 126 mg/dL o más en dos '
            'pruebas distintas pueden indicar diabetes. Estos valores '
            'son orientativos; siempre consulta a un médico.';
      }
    }

    if (_containsAny(text, [
      'azúcar',
      'azucar',
      'refresco',
      'dulces',
      'endulzante',
      'Azucar',
      ])) {
      return 'El azúcar añadida en los alimentos se debe consumir '
          'con moderación. Los refrescos, jugos industrializados y '
          'dulces aportan muchas calorías sin nutrientes. Prefiere '
          'agua, frutas enteras y endulzantes naturales con '
          'moderación. Leer etiquetas ayuda a identificar azúcares '
          'ocultos.';
    }

    if (_containsAny(text, [
      'cuánta agua',
      'cuanta agua',
      'hidratación',
      'hidratacion',
      'tomar agua',
      'beber agua',
    ])) {
      return 'La cantidad de agua que necesitas depende de tu edad, '
          'peso y actividad. Como referencia general, se suelen '
          'recomendar entre 6 y 8 vasos al día para adolescentes y '
          'adultos. Si haces ejercicio o hace mucho calor, aumenta '
          'un poco. Una buena señal es que tu orina sea de color '
          'claro.';
    }

    if (_containsAny(text, [
      'desayuno',
      'qué desayuno',
      'que desayuno',
      'ideas de desayuno',
    ])) {
      return 'Un buen desayuno combina tres cosas: una fuente de '
          'energía (avena, pan integral, fruta), algo de proteína '
          '(huevo, yogur, leche, frijoles) y una fruta o verdura. '
          'Ejemplos: avena con plátano y nueces, huevos con pan '
          'integral y una manzana, o yogur con fruta y granola sin '
          'azúcar añadida.';
    }

    if (_containsAny(text, [
      'calorías',
      'calorias',
      'cuántas calorías',
      'cuantas calorias',
    ])) {
      return 'Las calorías que necesitas varían según tu edad, sexo, '
          'peso y nivel de actividad. En lugar de contar cada '
          'caloría, enfócate en comer variado: verduras, frutas, '
          'proteínas, granos integrales y grasas saludables. Si '
          'quieres un cálculo personalizado, lo mejor es consultar '
          'con un nutriólogo.';
    }

    if (_containsAny(text, [
      'proteína',
      'proteina',
      'alimentos con proteína',
      'alimentos con proteina',
    ])) {
      return 'Buenas fuentes de proteína: huevo, pollo, pescado, '
          'carne magra, frijoles, lentejas, garbanzos, tofu, yogur '
          'griego, queso, leche y frutos secos. Intenta incluir una '
          'porción en cada comida principal para sentirte '
          'satisfecho por más tiempo.';
    }

    if (_containsAny(text, [
      'bajar de peso',
      'perder peso',
      'adelgazar',
      'dieta para bajar',
    ])) {
      return 'Para bajar de peso de forma saludable, lo importante '
          'no es dejar de comer, sino comer mejor: aumenta verduras '
          'y frutas, elige granos integrales, toma agua en lugar de '
          'refrescos y evita ultraprocesados. También ayuda moverte '
          'todos los días. Los cambios pequeños y constantes duran '
          'más que las dietas estrictas.';
    }

    if (_containsAny(text, [
      'snack',
      'snacks',
      'colación',
      'colacion',
      'entre comidas',
    ])) {
      return 'Ideas de snacks saludables: fruta fresca, yogur '
          'natural, un puñado de nueces o almendras, zanahoria o '
          'apio con hummus, palomitas caseras, huevo duro o un '
          'sándwich pequeño de pan integral. Lo importante es que '
          'combinen fibra y proteína para que te llenen.';
    }

    if (_containsAny(text, [
      'frutas',
      'verduras',
      'frutas y verduras',
      'porciones de fruta',
    ])) {
      return 'Se recomienda comer al menos 5 porciones de frutas y '
          'verduras al día. Varía los colores: verde, rojo, naranja '
          'y morado. Puedes agregarlas al desayuno, como snack, en '
          'la comida o la cena. No tienen que ser aburridas, prueba '
          'nuevas preparaciones.';
    }

    if (_containsAny(text, [
      'comida chatarra',
      'ultraprocesados',
      'procesados',
      'frituras',
    ])) {
      return 'Los ultraprocesados suelen tener mucha sal, azúcar y '
          'grasas poco saludables. No se trata de eliminarlos por '
          'completo, sino de reservarlos para ocasiones especiales '
          'y dar prioridad a alimentos frescos y naturales en tu '
          'día a día.';
    }

    if (_containsAny(text, [
      'vegetariano',
      'vegetariana',
      'vegano',
      'vegana',
    ])) {
      return 'Una alimentación vegetariana o vegana bien planeada '
          'puede ser muy saludable. Incluye leguminosas (frijol, '
          'lenteja, garbanzo), tofu, tempeh, frutos secos, semillas '
          'y granos integrales. Vigila la vitamina B12, hierro, '
          'calcio y omega-3; en dietas veganas la B12 suele '
          'requerir suplementación.';
    }

    if (_containsAny(text, [
      'ejercicio',
      'actividad física',
      'actividad fisica',
      'deporte',
    ])) {
      return 'Para acompañar tu alimentación, intenta moverte al '
          'menos 30 minutos al día: caminar, bailar, andar en bici '
          'o hacer deporte. Combina actividad aeróbica con algo de '
          'fuerza dos o tres veces por semana. Recuerda hidratarte '
          'antes, durante y después.';
    }

    if (_containsAny(text, [
      'hola',
      'buenos dias',
      'buenos días',
      'buenas tardes',
      'buenas noches',
      'Ola',
      'Buenas',
      'buenas',
    ])) {
      return '¡Hola! Estoy aquí para ayudarte con tus dudas de '
          'nutrición. Puedes preguntarme sobre alimentos, comidas, '
          'hidratación o hábitos saludables.';
    }

    if (_containsAny(text, [
      'gracias',
      'te agradezco',
    ])) {
      return '¡Con gusto! Recuerda que una alimentación variada y '
          'equilibrada es la mejor base para sentirte bien. Si '
          'tienes otra duda, aquí estoy.';
    }

    return 'Gracias por tu pregunta. Cuéntame un poco más para '
        'poder ayudarte mejor: ¿te interesa saber sobre algún '
        'alimento, una comida específica, hidratación o hábitos '
        'saludables?';
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((word) => text.contains(word));
  }

  void showHydrationDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const HydrationDialog(),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: verdeClaro,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              '- N U T R I -',
              style: TextStyle(
                color: textoOscuro,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Tu asistente de nutrición',
              style: TextStyle(
                color: textoOscuro,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(9),
          child: Container(
            decoration: const BoxDecoration(
              color: amarillo,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: verde,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Recordatorio de agua',
            onPressed: showHydrationDialog,
            icon: const Icon(
              Icons.water_drop_rounded,
              color: verde,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            color: verdeClaro.withValues(alpha: 0.55),
            child: const Text(
              'La información que doy es orientativa. Para un plan '
              'personalizado, consulta a un nutriólogo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoOscuro,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return const TypingIndicator();
                }

                return MessageBubble(
                  message: messages[index],
                );
              },
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            decoration: const BoxDecoration(
              color: fondo,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE3EAD9),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    '¿Sobre qué quieres saber?',
                    style: TextStyle(
                      color: textoOscuro,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickOptions.map((option) {
                    return OutlinedButton(
                      onPressed: isTyping
                          ? null
                          : () => sendMessage(option),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: verde,
                        backgroundColor:
                            verdeClaro.withValues(alpha: 0.45),
                        side: const BorderSide(
                          color: Color(0xFFC9DDB4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              color: fondo,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textCapitalization:
                          TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5EC),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton.filled(
                      onPressed:
                          isTyping ? null : () => sendMessage(),
                      tooltip: 'Enviar mensaje',
                      style: IconButton.styleFrom(
                        backgroundColor: verde,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: amarillo,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: verde,
                size: 18,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? verdeClaro : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFFC9DDB4)
                      : const Color(0xFFE6EDDD),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: textoOscuro,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 42, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Nutri está escribiendo...',
          style: TextStyle(
            color: verde,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class HydrationDialog extends StatefulWidget {
  const HydrationDialog({super.key});

  @override
  State<HydrationDialog> createState() => _HydrationDialogState();
}

class _HydrationDialogState extends State<HydrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    animation = Tween<double>(
      begin: 0.75,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: fondo,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      title: const Text(
        'Recordatorio de agua',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: verde,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Tomar agua suficiente ayuda a tu cuerpo a funcionar '
            'mejor. Lleva una botella contigo y bebe pequeños '
            'sorbos a lo largo del día.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textoOscuro,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: amarillo,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: verde.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    size: 45,
                    color: verde,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Meta sugerida: entre 6 y 8 vasos al día.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textoOscuro,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: verde,
            foregroundColor: Colors.white,
          ),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}