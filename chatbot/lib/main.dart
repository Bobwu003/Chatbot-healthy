import 'package:flutter/material.dart';
import 'nutri_calculator_service.dart';
import 'dart:math';
void main() {
  runApp(const NutriApp());
}
//Nueva paleta de colores
class AppColors {
  static const navy = Color(0xFF0E1A30);
  static const green = Color(0xFF34C77B);
  static const greenDark = Color(0xFF1FA866);
  static const yellowBg = Color(0xFFFCEEB5);
  static const purpleBg = Color(0xFFE6DDF7);
  static const purpleText = Color(0xFF8B5CF6);
  static const mintBg = Color(0xFFCFF3DD);
  static const blue = Color(0xFF3B82F6);
  static const textDark = Color(0xFF14171F);
  static const textGrey = Color(0xFF8A8F98);

  // La nueva paleta no trae fondo; conservo el anterior (casi blanco).
  static const background = Color(0xFFFCFBFF);
}

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Healthy - Asistente de Nutrición', //Cambiar lo de "title"
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          primary: AppColors.green,
          surface: AppColors.background,
          onSurface: AppColors.textDark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const NutriChatPage(),
    );
  }
}

/////////////////////////////////
///


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
  final NutriCalculatorService _calculatorService = NutriCalculatorService();
  bool isTyping = false;

  final List<ChatMessage> messages = [
    ChatMessage(
      text: '¡Hola! Soy Mr.Healthy, soy tu asistente personalizado. '
          'Puedo ayudarte con dudas sobre habitos saludables, ideas de '
          'comidas, hidratación. '
          '¿Sobre qué te gustaría saber?',
      isUser: false,
    ),
  ];

  final List<String> quickOptions = [
    '¿Cuánta agua debo tomar al día?',
    '¿Es mejor comer antes o después de entrenar?',
    '¿Como funciona el mecanismo de retroalimentación?',
    '¿Como funciona las evidencias?',
    '¿Cómo gano experiencia (XP) y subo de nivel?',
    'Ideas de snacks saludables para la tarde',
    'Sugerir un nuevo hábito saludable',
    'Explicar un habito',
    'Calcular mi IMC',
    'Calcular mi GET',
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
    final respuesta = _calculatorService.procesarMensaje(text);
    final response =
        respuesta.isNotEmpty ? respuesta : getNutriResponse(text);
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
  // Servicio para cálculos de nutrición (IMC y GET)
   

  String getNutriResponse(String input) {
    final text = input.toLowerCase();

    

    if (_containsAny(text, [
      'Experiencia',
      'experiencia',
      'xp',
      'XP',
      'Xp',
      'Azucar',
      'Nivel',
      'nivel',
      'subir de nivel',
      'Subir de nivel',
      ])) {
      return 'Ganas experiencia (XP) al registrar tus evidencias. '
          'fotograficas, al cumplir los desafios, . '
          'y para pasar el siguiente nivel necesitas'
          'completar el nivel al 100% y asi poder desbloquear el siguiente nivel, '
          ;
    }

    if (_containsAny(text, [
      'Fotografía de alimentos',
      'fotografia',
      'Evidencias',
      'evidencias',
      
    ])) {
      return 'La evidencias fotograficas funcionan por medio, '
          'de que avance la dificultad de los desafios, '
          'a apartir de la dificultad media hasta la alta,'
          'son de manera opcional que permite que se verifiquen'
          'si se estan cumpliendo los desafios, y que se pueda ver el progreso de la persona, '
          ;
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
      'alimentos proteicos', //Modificación. Añadir línea
      'comidas con proteina', //Modificación. Añadir línea
      'comidas proteicas', //Modificación. Añadir línea
      'comidas con proteína', //Modificación. Añadir línea
    ])) {
      return 'Buenas fuentes de proteína: huevo, pollo, pescado, '
          'carne magra, frijoles, lentejas, garbanzos, tofu, yogur '
          'griego, queso, leche y frutos secos. Intenta incluir una '
          'porción en cada comida principal para sentirte '
          'satisfecho por más tiempo.';
    }

    if (_containsAny(text, [
      'Agua',
      'agua',
      '¿Cuanta agua debo tomar al día?',
      '¿cuánta agua debo tomar al día?',
      '¿Cuánta agua debo tomar al día?',
      '¿Cuanta agua debo tomar al dia?',
      'Cuánta agua debo tomar al dia',
      'cuanta agua debo tomar al dia',
      'cuánta agua debo tomar al día',
      
    ])) {
      return 'Multiplica tu peso corporal por 35 mililitros. Por  '
          'ejemplo, si pesas 70 kg, necesitas unos 2.45 litros al día. '
          ;
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
      'vegetales', //Modificación. Añadir línea
      'porcion de fruta', //Modificación. Añadir línea
      'porción de fruta', //Modificación. Añadir línea
      'frutas y vegetales', //Modificación. Añadir línea
    ])) {
      return 'Se recomienda comer al menos 5 porciones de frutas y '
          'verduras al día. Varía los colores: verde, rojo, naranja '
          'y morado. Puedes agregarlas al desayuno, como snack, en '
          'la comida o la cena. No tienen que ser aburridas, prueba '
          'nuevas preparaciones.';
    }

    

    if (_containsAny(text, [
      'Retroalimentacion',
      'Retroalimentacion',
      'retroalimentación',
      'retroalimentacion',
    ])) {
      return 'Permite analizar el progreso registrado, '
          'y generar sugerencias de habitos acordes, '
          'con los objetivos del usuario, ';
          
    }

    if (text.contains('entren') &&
        _containsAny(text, ['antes', 'después', 'despues'])) {
      return 'Depende de la duración e intensidad del ejercicio y de '
          'cómo te sientas. Si vas a comer una comida completa antes '
          'de entrenar, intenta hacerlo entre 1 y 3 horas antes; si '
          'falta poco, elige algo ligero que te siente bien. Después '
          'de entrenar, procura incluir proteína y carbohidratos en '
          'tu siguiente comida; no es necesario comer '
          'inmediatamente. Mantente bien hidratado.';
    }

    //Nueva pregunta para alternativas sin aceite
    if (_containsAny(text, [
      'cocina sin aceite',
      'recetas sin aceite',
      'cocinar sin aceite',
      'alternativas al aceite para cocinar',
      'reemplazar el aceite',
      'sin aceite',
      'evitar aceite',
      'evitar el aceite',
      'alimentos sin aceite',
      'comidas sin aceite',
    ])) {
      return 'Las técnicas de cocina sin aceite permiten preparar '
          'alimentos de forma más saludable, reduciendo el uso de grasas '
          'añadidas sin perder su sabor. Una de ellas es cocinar al vapor, '
          'ideal para verduras y pescado; otra es hornear, por ejemplo, '
          'papas o pollo. También se puede utilizar una freidora de aire, '
          'que cocina alimentos como papas fritas o alitas con poco o nada '
          'de aceite. Finalmente, está la cocción a la plancha antiadherente, '
          'que permite preparar huevos, carnes y verduras sin necesidad de '
          'añadir grasa.';
    }
    /////////////////////

    //Explicar un habito
    if (_containsAny(text, [
      'como funciona un habito',
      'como funciona un hábito',
      'explica un habito',
      'explica un hábito',
      'de los hábitos',
      'sobre los hábitos',
      'de los habitos',
      'sobre los habitos',
    ])) {
      return 'Los hábitos saludables de alimentación y actividad física '
          'son fundamentales para mantener una buena salud y prevenir '
          'enfermedades. Una alimentación equilibrada incluye frutas, verduras, '
          'cereales, proteínas y suficiente agua, evitando el consumo excesivo '
          'de azúcar, grasas y comida chatarra. Además, realizar actividad física '
          'regularmente, como caminar, correr, bailar o practicar algún deporte, '
          'ayuda a fortalecer los músculos, mejorar la condición física y reducir '
          'el estrés';
    }
    //////////////////
    //Sugerencia de nuevos habitos

    const List<String> _consejosHabitos = [
      '1. Bebe un vaso de agua al despertar y mantén una botella a la mano durante el día.',
      '2. Añade una porción de verdura o fruta a cada comida.',
      '3. Camina al menos 20-30 minutos al día; empieza con 10 si te cuesta.',
      '4. Duerme entre 7 y 9 horas y trata de acostarte a la misma hora.',
      '5. Come despacio y sin pantallas para notar cuándo ya estás satisfecho.',
      '6. Planea tus comidas de la semana y haz tu lista de compras con tiempo.',
      '7. Cambia un refresco o jugo azucarado al día por agua o agua con limón.',
      '8. Ten a la vista snacks saludables: fruta, nueces o yogur natural.',
      '9. Reduce poco a poco la sal y los ultraprocesados; lee las etiquetas.',
      '10. Cambia un solo hábito a la vez y repítelo 3-4 semanas hasta que sea automático.',
    ];

    if (_containsAny(text, [
      'nuevo habito',
      'sugiere un habito',
      'sugerencia de un habito',
      'nuevo hábito',
      'ejemplo de habito',
      'ejemplo de hábito',
      'recomendación de hábito',
      'sugiéreme un hábito',
      'recomiéndame un hábito',
      'recomiendame un habito',
      'sugiereme un habito',
    ])) {
      final random = Random();
      final consejo = _consejosHabitos[random.nextInt(_consejosHabitos.length)];
      return '¡Claro! Aquí tienes un hábito saludable para empezar:\n\n'
          '$consejo\n\n'
          'Escribe "más hábitos" si quieres ver los diez consejos.';
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
        backgroundColor: AppColors.mintBg,
        elevation: 0,
        centerTitle: true,
        title: const Column(
          children: [
            Text(
              '- M R.  H E A L T H Y -', //Cambiar el título a Mr. Healthy
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Tu asistente de nutrición',
              style: TextStyle(color: AppColors.textDark, fontSize: 12),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(9),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.yellowBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_rounded, color: AppColors.green),
          ),
        ),
      ),
     body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.mintBg.withValues(alpha: 0.55),
            child: const Text(
              'La información que doy es orientativa. Para un plan '
              'personalizado, consulta a un nutriólogo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDark, fontSize: 12),
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
              color: AppColors.background,
              border: Border(top: BorderSide(color: Color(0xFFE3EAD9))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    '¿Sobre qué quieres saber?',
                    style: TextStyle(
                      color: AppColors.textDark,
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
                      onPressed: isTyping ? null : () => sendMessage(option),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.green,
                        backgroundColor: AppColors.mintBg.withValues(
                          alpha: 0.45,
                        ),
                        side: const BorderSide(color: Color(0xFFC9DDB4)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(option, style: const TextStyle(fontSize: 12)),
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
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu pregunta...',
                        filled: true,
                        fillColor: const Color(0xFFF1F5EC),
                        contentPadding: const EdgeInsets.symmetric(
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
                      onPressed: isTyping ? null : () => sendMessage(),
                      tooltip: 'Enviar mensaje',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.green,
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
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.yellowBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.green,
                size: 18,
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.mintBg : Colors.white,
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
                  color: AppColors.textDark,
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
            color: AppColors.green,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
