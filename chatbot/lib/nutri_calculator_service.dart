class NutriCalculatorService {
  // Estados para IMC
  int pasoIMC = 0;
  double? pesoUsuario;

  // Estados para GET
  int pasoGET = 0;
  String? sexoGET;
  double? pesoGET;
  double? alturaGET;
  int? edadGET;
  double? factorActividadGET;
  double? porcentajeTAGET;
  double? tmbGET;
  double? gebGET;
  double? etaGET;
  double? taGET;
  String? formulaUsadaGET;
  double? getTotalGET;

  void resetGET() {
    pasoGET = 0;
    sexoGET = null;
    pesoGET = null;
    alturaGET = null;
    edadGET = null;
    factorActividadGET = null;
    porcentajeTAGET = null;
    tmbGET = null;
    gebGET = null;
    etaGET = null;
    taGET = null;
    formulaUsadaGET = null;
    getTotalGET = null;
  }

  void resetIMC() {
    pasoIMC = 0;
    pesoUsuario = null;
  }

  String procesarMensaje(String input) {
    final text = input.toLowerCase();

    // ==========================================
    // 1. FLUJO DE GASTO ENERGÉTICO TOTAL (GET)
    // ==========================================
    if (pasoGET == 1) {
      if (_containsAny(text, ['hombre', 'masculino'])) {
        sexoGET = 'hombre';
        pasoGET = 2;
        return 'Perfecto. ¿Cuál es tu peso en kilogramos? Por ejemplo: 70';
      }
      if (_containsAny(text, ['mujer', 'femenino'])) {
        sexoGET = 'mujer';
        pasoGET = 2;
        return 'Perfecto. ¿Cuál es tu peso en kilogramos? Por ejemplo: 60';
      }
      if (_containsAny(text, ['si', 'sí', 'claro', 'ok', 'dale'])) {
        return 'Perfecto. Primero dime tu sexo: escribe "hombre" o "mujer".';
      }
      if (_containsAny(text, ['no', 'nope', 'no gracias', 'nel', 'luego', 'despues', 'después', 'mejor no'])) {
        resetGET();
        return 'Está bien. Si en otro momento quieres calcularlo, aquí estaré.';
      }
      return 'Por favor dime tu sexo: escribe "hombre" o "mujer".';
    }

    if (pasoGET == 2) {
      final peso = double.tryParse(text.replaceAll(',', '.'));
      if (peso == null || peso <= 0 || peso > 500) {
        return 'No entendí tu peso. Escríbelo en kilogramos, por ejemplo: 70';
      }
      pesoGET = peso;
      pasoGET = 3;
      return 'Gracias. Ahora dime tu altura en metros, por ejemplo: 1.70';
    }

    if (pasoGET == 3) {
      double? altura = double.tryParse(text.replaceAll(',', '.'));
      if (altura == null || altura <= 0) {
        return 'No entendí tu altura. Escríbela en metros, por ejemplo: 1.70';
      }
      if (altura > 3) altura = altura / 100;
      alturaGET = altura;
      pasoGET = 4;
      return 'Gracias. Ahora dime tu edad en años, por ejemplo: 25';
    }

    if (pasoGET == 4) {
      final edad = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (edad == null || edad <= 0 || edad > 120) {
        return 'No entendí tu edad. Escríbela en años, por ejemplo: 25';
      }
      edadGET = edad;
      pasoGET = 5;
      return 'Ahora dime tu nivel de actividad física:\n\n'
          '1. Muy sedentaria (poco o nada de ejercicio) → TA 30%\n'
          '2. Sedentaria (ejercicio ligero) → TA 50%\n'
          '3. Moderada (3-5 días por semana) → TA 75%\n'
          '4. Activa (6-7 días por semana) → TA 100%\n\n'
          'Responde con el número o la palabra.';
    }

    if (pasoGET == 5) {
      double? factor;
      double? porcentajeTA;
      if (_containsAny(text, ['1', 'muy sedentario', 'muy sedentaria'])) {
        factor = 1.25;
        porcentajeTA = 0.30;
      } else if (_containsAny(text, ['2', 'sedentario', 'sedentaria'])) {
        factor = 1.5;
        porcentajeTA = 0.50;
      } else if (_containsAny(text, ['3', 'moderado', 'moderada'])) {
        factor = 1.75;
        porcentajeTA = 0.75;
      } else if (_containsAny(text, ['4', 'activo', 'activa', 'atleta'])) {
        factor = 2.2;
        porcentajeTA = 1.00;
      }

      if (factor == null || porcentajeTA == null) {
        return 'No entendí tu nivel de actividad. Elige un número del 1 al 4.';
      }

      factorActividadGET = factor;
      porcentajeTAGET = porcentajeTA;
      pasoGET = 6;
      return '¿Qué fórmula prefieres usar para calcular tu GET?\n\n'
          '1. Harris-Benedict (clásica)\n'
          '2. Mifflin-St Jeor (moderna, más precisa)\n'
          '3. Valencia (por rango de edad, desde 18 años)\n'
          '4. FAO/OMS/UNU (solo menores de 3 años)\n'
          '5. Gasto Energético por edad (peso × factor + constante)\n'
          '6. Regla del pulgar (25-35 kcal/kg/día)\n\n'
          'Responde con el número.';
    }

    if (pasoGET == 6) {
      double? tmb;
      String formulaUsada = '';

      final peso = pesoGET ?? 0;
      final alturaCm = (alturaGET ?? 0) * 100;
      final edad = edadGET ?? 0;
      final sexo = sexoGET ?? 'hombre';

      if (_containsAny(text, ['1', 'harris', 'harris-benedict', 'clasica', 'clásica'])) {
        if (sexo == 'hombre') {
          tmb = 66.5 + (13.75 * peso) + (5.0 * alturaCm) - (6.78 * edad);
        } else {
          tmb = 655 + (9.56 * peso) + (1.85 * alturaCm) - (4.86 * edad);
        }
        formulaUsada = 'Harris-Benedict';
      } else if (_containsAny(text, ['2', 'mifflin', 'mifflin-st jeor', 'mifflin st jeor'])) {
        if (sexo == 'hombre') {
          tmb = (10 * peso) + (6.25 * alturaCm) - (5 * edad) + 5;
        } else {
          tmb = (10 * peso) + (6.25 * alturaCm) - (5 * edad) - 161;
        }
        formulaUsada = 'Mifflin-St Jeor';
      } else if (_containsAny(text, ['3', 'valencia'])) {
        if (sexo == 'mujer') {
          tmb = (edad <= 30) ? 11.02 * peso + 649 : (edad <= 60 ? 10.92 * peso + 677 : 10.98 * peso + 429);
        } else {
          tmb = (edad <= 30) ? 13.37 * peso + 747 : (edad <= 60 ? 13.08 * peso + 693 : 14.21 * peso + 429);
        }
        formulaUsada = 'Valencia';
      } else if (_containsAny(text, ['4', 'fao', 'oms', 'onu'])) {
        if (edad >= 3) {
          return 'La fórmula FAO/OMS/UNU solo aplica a menores de 3 años.';
        }
        tmb = (sexo == 'hombre') ? 60.9 * peso - 54 : 61.0 * peso - 51;
        formulaUsada = 'FAO/OMS/UNU';
      } else if (_containsAny(text, ['5', 'por edad', 'gasto energetico por edad'])) {
        if (sexo == 'hombre') {
          tmb = edad < 3 ? 59.512 * peso + 30.4 : (edad <= 10 ? 22.706 * peso + 504.3 : (edad <= 18 ? 17.686 * peso + 658.2 : (edad <= 30 ? 15.057 * peso + 692.2 : (edad <= 60 ? 11.472 * peso + 873.1 : 11.711 * peso + 587.7))));
        } else {
          tmb = edad < 3 ? 58.317 * peso + 31.1 : (edad <= 10 ? 20.315 * peso + 485.9 : (edad <= 18 ? 13.384 * peso + 692.6 : (edad <= 30 ? 14.818 * peso + 486.6 : (edad <= 60 ? 8.126 * peso + 845.6 : 9.082 * peso + 658.5))));
        }
        formulaUsada = 'Gasto Energético por edad';
      } else if (_containsAny(text, ['6', 'pulgar', 'regla del pulgar'])) {
        final minimo = 25 * peso;
        final maximo = 35 * peso;
        resetGET();
        return 'Según la Regla del Pulgar, tu GET está entre:\n• Mínimo: ${minimo.toStringAsFixed(0)} kcal/día\n• Máximo: ${maximo.toStringAsFixed(0)} kcal/día';
      } else {
        return 'No entendí tu elección. Responde un número del 1 al 6.';
      }

      gebGET = tmb;
      etaGET = tmb * 0.10;
      taGET = tmb * (porcentajeTAGET ?? 0.30);
      formulaUsadaGET = formulaUsada;

      pasoGET = 7;
      return '¿Estás en periodo de lactancia materna exclusiva? (Responde "sí" o "no")';
    }

    if (pasoGET == 7) {
      int lactancia = 0;
      if (_containsAny(text, ['si', 'sí', 'claro', 'ok', 'yes', 'dale'])) {
        lactancia = 310;
      } else if (_containsAny(text, ['no', 'nope', 'no gracias', 'nel'])) {
        lactancia = 0;
      } else {
        return 'Por favor responde "sí" o "no" para continuar.';
      }

      final geb = gebGET ?? 0;
      final eta = etaGET ?? 0;
      final ta = taGET ?? 0;
      final getTotal = geb + eta + ta + lactancia;
      getTotalGET = getTotal;
      pasoGET = 8;

      return 'Tu Gasto Energético Total (GET) usando $formulaUsadaGET es ${getTotal.toStringAsFixed(0)} kcal/día.\n\n¿Quieres ver la distribución de macronutrientes? (Responde "sí" o "no")';
    }

    if (pasoGET == 8) {
      if (_containsAny(text, ['si', 'sí', 'claro', 'ok', 'dale', 'yes'])) {
        pasoGET = 9;
        return '¿Qué tipo de distribución prefieres?\n1. Balanceada (50% HC / 30% Lípidos / 20% Proteínas)\n2. Estándar (60% HC / 25% Lípidos / 15% Proteínas)\n3. Baja en carbohidratos (40% / 35% / 25%)\n4. Alta en proteínas (45% / 25% / 30%)\nResponde con el número.';
      }
      resetGET();
      return '¡Entendido!';
    }

    if (pasoGET == 9) {
      double? pHC, pLipidos, pProt;
      String tipo = '';

      if (_containsAny(text, ['1', 'balanceada'])) {
        pHC = 0.50; pLipidos = 0.30; pProt = 0.20; tipo = 'Balanceada';
      } else if (_containsAny(text, ['2', 'estandar', 'estándar'])) {
        pHC = 0.60; pLipidos = 0.25; pProt = 0.15; tipo = 'Estándar';
      } else if (_containsAny(text, ['3', 'baja en carbohidratos', 'low carb'])) {
        pHC = 0.40; pLipidos = 0.35; pProt = 0.25; tipo = 'Baja en carbohidratos';
      } else if (_containsAny(text, ['4', 'alta en proteinas', 'alta en proteínas'])) {
        pHC = 0.45; pLipidos = 0.25; pProt = 0.30; tipo = 'Alta en proteínas';
      } else {
        return 'No entendí tu elección. Responde un número del 1 al 4.';
      }

      final get = getTotalGET ?? 0;
      final gHC = (get * pHC) / 4;
      final gLip = (get * pLipidos) / 9;
      final gProt = (get * pProt) / 4;

      resetGET();
      return 'Distribución ($tipo) para ${get.toStringAsFixed(0)} kcal:\n• Hidratos de carbono: ${gHC.toStringAsFixed(1)} g\n• Lípidos: ${gLip.toStringAsFixed(1)} g\n• Proteínas: ${gProt.toStringAsFixed(1)} g';
    }

    // ==========================================
    // 2. FLUJO DE ÍNDICE DE MASA CORPORAL (IMC)
    // ==========================================
    if (pasoIMC == 1) {
      if (_containsAny(text, ['si', 'sí', 'claro', 'ok', 'dale', 'yes'])) {
        pasoIMC = 2;
        return '¿Cuál es tu peso en kilogramos? Por ejemplo: 65';
      }
      resetIMC();
      return 'Está bien.';
    }

    if (pasoIMC == 2) {
      final peso = double.tryParse(text.replaceAll(',', '.'));
      if (peso == null || peso <= 0 || peso > 500) {
        return 'No entendí tu peso. Escríbelo en kilogramos, por ejemplo: 65';
      }
      pesoUsuario = peso;
      pasoIMC = 3;
      return 'Gracias. Ahora dime tu altura en metros, por ejemplo: 1.70';
    }

    if (pasoIMC == 3) {
      double? altura = double.tryParse(text.replaceAll(',', '.'));
      if (altura == null || altura <= 0) {
        return 'No entendí tu altura. Escríbela en metros, por ejemplo: 1.70';
      }
      if (altura > 3) altura = altura / 100;
      final imc = (pesoUsuario ?? 0) / (altura * altura);
      resetIMC();

      String clasificacion = imc < 18.5
          ? 'Bajo peso'
          : imc < 25
              ? 'Peso normal'
              : imc < 30
                  ? 'Sobrepeso'
                  : 'Obesidad';

      return 'Tu IMC es ${imc.toStringAsFixed(1)} kg/m², lo que corresponde a: $clasificacion.';
    }

    if (_containsAny(text, ['get', 'gasto energetico', 'gasto energético', 'calorias diarias'])) {
      pasoGET = 1;
      return 'El Gasto Energético Total (GET) calcula tus calorías diarias. ¿Quieres calcular el tuyo? Responde "sí".';
    }

    if (_containsAny(text, ['imc', 'indice de masa corporal', 'índice de masa corporal'])) {
      pasoIMC = 1;
      return 'El IMC evalúa tu peso en relación con tu altura. ¿Quieres calcular tu IMC? Responde "sí".';
    }

    return '';
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((word) => text.contains(word));
  }
  
}