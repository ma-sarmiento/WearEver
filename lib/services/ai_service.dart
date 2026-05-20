class AiService {
  static const _responses = {
    'saludo': [
      '¡Hola! Soy Tito, tu asistente de moda en WearEver. '
          'Estoy aquí para ayudarte a encontrar prendas, armar outfits y tomar decisiones sostenibles. '
          '¿En qué te puedo ayudar hoy?',
      '¡Quiubo! Bienvenido a WearEver, la app de moda circular de Colombia. '
          'Soy Tito y estoy listo para ayudarte con todo lo que necesites sobre moda sostenible. '
          '¿Qué se te ofrece?',
      '¡Hola, hola! Me da mucho gusto saludarte. '
          'Soy Tito, el asistente de moda de WearEver. '
          'Cuéntame, ¿qué andas buscando hoy?',
    ],
    'moda': [
      '¡Claro que sí! En WearEver encontrarás prendas únicas para armar looks increíbles. '
          'Te recomiendo combinar básicos neutros con una pieza llamativa para un outfit equilibrado. '
          '¿Quieres explorar el catálogo?',
      'Combinar bien la ropa es todo un arte, pero con práctica queda chimba. '
          'En WearEver puedes encontrar piezas de segunda mano de excelente calidad para renovar tu estilo. '
          'Lo mejor es que también ayudas al planeta haciéndolo.',
      '¡Uy, ese tema me encanta! Un tip clave: invierte en prendas versátiles que puedas mezclar. '
          'En WearEver hay opciones para todos los estilos y presupuestos. '
          'Dale una mirada al catálogo y seguro encuentras algo que te guste.',
      'El estilo personal se construye con prendas que realmente te representen. '
          'En WearEver hay ropa vintage, streetwear, casual y elegante, todo en un solo lugar. '
          '¡Explora y encuentra tu look!',
    ],
    'precio': [
      'En WearEver consigues ropa de buena calidad a precios mucho más accesibles que en tiendas nuevas. '
          'La moda circular es perfecta para renovar el clóset sin quebrar el bolsillo. '
          '¡Explora el catálogo y sorpréndete con los precios!',
      '¡La ropa de segunda mano es la mejor opción para ahorrar sin sacrificar estilo! '
          'En WearEver puedes encontrar prendas en excelente estado a precios muy buenos. '
          'Revisa la sección de explorar para ver todas las opciones.',
      'El precio justo en WearEver lo define el vendedor según el estado de la prenda. '
          'Si ves algo que te gusta pero está un poco caro, puedes chatear con el vendedor para negociar. '
          '¡En WearEver todo es posible!',
    ],
    'donacion': [
      'Donar ropa es una de las acciones más bonitas que puedes hacer. '
          'En WearEver puedes conectarte directamente con ONGs que necesitan tu ayuda. '
          '¡Ve a la sección de ONGs y encuentra una fundación cerca de ti!',
      '¡Qué gesto tan bacano el de donar! Cada prenda que donas puede cambiarle el día a alguien. '
          'En WearEver tenemos alianzas con varias fundaciones en Colombia. '
          'Entra a la sección de ONGs y encuentra cómo colaborar.',
      'Donar es más fácil de lo que crees. Selecciona las prendas que ya no usas, '
          'conéctate con una ONG en WearEver y coordina la entrega. '
          '¡Tu clóset puede hacer una gran diferencia!',
    ],
    'sostenible': [
      'La moda circular es clave para reducir el impacto ambiental del sector textil. '
          'En Colombia se generan miles de toneladas de residuos textiles al año, y WearEver existe para cambiar eso. '
          '¡Cada prenda que reusan o donas hace la diferencia!',
      '¡Me alegra que te interese la moda sostenible! Comprar ropa de segunda mano reduce la huella de carbono. '
          'WearEver es tu aliado para consumir moda de forma responsable y consciente. '
          'Juntos podemos hacer Colombia más verde.',
      'Elegir moda circular no es solo una tendencia, es una decisión de vida. '
          'Al comprar en WearEver evitas que prendas en buen estado terminen en el relleno sanitario. '
          '¡Tú marcas la diferencia!',
    ],
    'talla': [
      'Para elegir bien la talla en ropa de segunda mano, siempre revisa las medidas del vendedor. '
          'En WearEver cada prenda tiene su talla indicada y puedes chatear con el vendedor para más detalles. '
          '¡No dudes en preguntar antes de comprar!',
      'Las tallas pueden variar mucho según la marca y el origen de la prenda. '
          'Mi consejo es que siempre compares con prendas que ya tienes y te queden bien. '
          'En WearEver puedes filtrar por talla para facilitar la búsqueda.',
      'Si tienes dudas entre dos tallas, generalmente es mejor ir a la más grande, '
          'especialmente en prendas vintage que pueden estar algo encogidas. '
          'Recuerda que en WearEver puedes hablar directamente con el vendedor para resolver dudas.',
    ],
    'vendedor': [
      '¡Vender en WearEver es súper fácil! Solo toca el botón + en el home, tomas fotos de tu prenda, '
          'pones el precio y listo. Tito mismo te ayuda a evaluar si está en condiciones de venta. '
          '¿Quieres intentarlo?',
      'Para vender bien en WearEver te recomiendo tomar fotos con buena luz y fondo limpio. '
          'Describe bien el estado de la prenda y pon un precio justo. '
          '¡Las prendas con buenas fotos se venden 3 veces más rápido!',
      '¡Anímate a vender esa ropa que ya no usas! En WearEver miles de personas están buscando prendas como la tuya. '
          'Sube tu publicación y empieza a generar ingresos con tu clóset.',
    ],
    'comprar': [
      'Para comprar en WearEver explora el catálogo en el home o usa la búsqueda. '
          'Cuando encuentres algo que te guste, revisa bien las fotos y la descripción antes de agregarlo al carrito. '
          '¿Necesitas ayuda para encontrar algo específico?',
      '¡Comprar ropa de segunda mano en WearEver es una experiencia increíble! '
          'Puedes filtrar por estilo, talla y precio. '
          'Si tienes dudas sobre una prenda, chatea directamente con el vendedor.',
      'Antes de comprar te recomiendo revisar el perfil del vendedor y su calificación. '
          'En WearEver todos los vendedores tienen reseñas de compradores anteriores. '
          '¡Eso te da mucha tranquilidad!',
    ],
    'cuidado': [
      'Para que tu ropa dure más tiempo, lávala al revés y con agua fría. '
          'Las prendas delicadas mejor lavarlas a mano. '
          '¡Una prenda bien cuidada puede durar años y luego venderse en WearEver!',
      'El secreto para que la ropa de segunda mano quede como nueva es lavarla bien al recibirla. '
          'Usa suavizante y sécala a la sombra para proteger los colores. '
          '¡Así cualquier prenda queda impecable!',
    ],
    'tendencia': [
      'En 2025 las tendencias en Colombia apuntan al streetwear oversized, los colores tierra y el vintage de los 90s. '
          '¡En WearEver encuentras prendas de todas estas tendencias a precios increíbles!',
      '¡La moda sostenible es la tendencia más importante del momento! '
          'Cada vez más personas prefieren comprar ropa de segunda mano. '
          'En WearEver estás a la vanguardia de esta tendencia global.',
      'Los básicos nunca pasan de moda: jeans, camisetas blancas, chaquetas de jean. '
          'En WearEver encuentras estos básicos de calidad a muy buen precio. '
          '¡Arma tu guardarropa cápsula!',
    ],
    'buscar': [
      'Para encontrar prendas específicas usa la lupa en el menú de abajo. '
          'Puedes buscar por nombre, marca o estilo. '
          'También puedes explorar por categorías en la sección Explorar.',
      '¡En WearEver hay miles de prendas! Si buscas algo específico te recomiendo usar los filtros '
          'de categoría en la pantalla Explorar. '
          'También puedes seguir vendedores que tengan tu estilo.',
    ],
    'pedido': [
      'Puedes revisar el estado de tus pedidos en tu perfil, sección Mis pedidos. '
          'Ahí ves si está pendiente, preparando, enviado o entregado. '
          '¿Tienes algún problema con un pedido específico?',
      'Los envíos en WearEver se hacen por Servientrega. '
          'El estándar tarda 3-5 días hábiles y el exprés 24-48 horas. '
          'Cuando tu pedido sea enviado recibirás una notificación con el número de guía.',
    ],
    'puntos': [
      '¡Los puntos de WearEver son tu recompensa por ser sostenible! '
          'Ganas puntos al donar ropa, vender y hacer compras. '
          'Próximamente podrás canjearlos por descuentos en la app.',
      'El sistema de puntos de WearEver premia a quienes más aportan a la moda circular. '
          'Mientras más donas y vendes, más puntos acumulas. '
          '¡Es nuestra forma de decirte gracias por cuidar el planeta!',
    ],
    'perfil': [
      'Tu perfil en WearEver muestra tus compras, ventas, seguidores y tus estilos favoritos. '
          'Puedes editarlo tocando el ícono de persona en el menú inferior. '
          '¡Hazlo tuyo!',
      'En tu perfil puedes gestionar tus publicaciones, ver tus pedidos y cambiar tus preferencias de estilo. '
          'También puedes seguir a tus vendedores favoritos para no perderte sus nuevas publicaciones.',
    ],
    'general': [
      'Qué buena pregunta. En WearEver nos apasiona la moda sostenible y circular. '
          'Puedo ayudarte con outfits, precios, donaciones o encontrar la prenda perfecta. '
          '¿Qué necesitas?',
      'Gracias por escribirme. Soy Tito, tu asistente de moda en WearEver. '
          'Puedo ayudarte a encontrar prendas, combinar looks o conectarte con ONGs. '
          '¿Por dónde empezamos?',
      'Interesante lo que me dices. En WearEver encontrarás todo lo que necesitas '
          'para vestir bien y de forma responsable. '
          '¿Quieres que te ayude a explorar el catálogo o prefieres información sobre donaciones?',
      '¡Esa es una muy buena consulta! WearEver nació para transformar la forma en que '
          'los colombianos consumen moda. ¿Te cuento más sobre cómo funciona la app?',
      'Me alegra que estés explorando WearEver. Aquí puedes comprar, vender, donar y conectarte '
          'con ONGs, todo en un solo lugar. ¿En qué parte te puedo orientar?',
      'Recuerda que en WearEver cada acción cuenta: comprar de segunda mano, donar, vender '
          'o reciclar. Soy Tito y estoy aquí para guiarte en cada paso. ¿Qué necesitas saber?',
    ],
  };

  Future<String> chat(String message, {String? context}) async {
    final lower = message.toLowerCase();

    String category;
    if (_containsAny(lower, ['hola', 'buenas', 'hey', 'quiubo', 'buen día', 'buenos días', 'buenas tardes'])) {
      category = 'saludo';
    } else if (_containsAny(lower, ['vender', 'publicar', 'subir', 'publicación', 'poner a la venta', 'cómo vendo'])) {
      category = 'vendedor';
    } else if (_containsAny(lower, ['comprar', 'adquirir', 'conseguir', 'carrito', 'cómo compro', 'quiero comprar'])) {
      category = 'comprar';
    } else if (_containsAny(lower, ['pedido', 'envío', 'entrega', 'paquete', 'guía', 'llegó', 'cuando llega'])) {
      category = 'pedido';
    } else if (_containsAny(lower, ['puntos', 'recompensa', 'beneficio', 'canjear', 'acumular'])) {
      category = 'puntos';
    } else if (_containsAny(lower, ['perfil', 'cuenta', 'configuración', 'mis datos', 'editar perfil'])) {
      category = 'perfil';
    } else if (_containsAny(lower, ['buscar', 'encontrar', 'dónde hay', 'busco', 'tendrán', 'hay disponible'])) {
      category = 'buscar';
    } else if (_containsAny(lower, ['tendencia', 'está de moda', 'qué se usa', 'moda actual', '2025', 'in', 'de moda'])) {
      category = 'tendencia';
    } else if (_containsAny(lower, ['lavar', 'lavo', 'cuidar', 'mantener', 'conservar', 'cuidado', 'limpieza'])) {
      category = 'cuidado';
    } else if (_containsAny(lower, ['estilo', 'outfit', 'combinar', 'prenda', 'ropa', 'look', 'vestir', 'moda', 'clóset'])) {
      category = 'moda';
    } else if (_containsAny(lower, ['precio', 'costo', 'barato', 'económico', 'caro', 'plata', 'pesos', 'cuánto vale'])) {
      category = 'precio';
    } else if (_containsAny(lower, ['donar', 'donación', 'ong', 'fundación', 'regalar', 'ayudar', 'ayuda'])) {
      category = 'donacion';
    } else if (_containsAny(lower, ['reciclar', 'reciclaje', 'medio ambiente', 'sostenible', 'circular', 'planeta', 'ecológico'])) {
      category = 'sostenible';
    } else if (_containsAny(lower, ['talla', 'medida', 'size', 'talle', 'número', 'me queda', 'me sirve'])) {
      category = 'talla';
    } else {
      category = 'general';
    }

    final options = _responses[category]!;
    final index = message.length % options.length;
    return options[index];
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  Future<Map<String, dynamic>> scanPrenda(String base64Image) async {
    final size = base64Image.length;

    if (size > 666000) {
      return {
        'grado': 'A',
        'descripcion': 'La prenda luce en excelente estado, con colores vivos y sin señales visibles de desgaste. '
            'La tela se ve en perfectas condiciones para seguir usándose.',
        'recomendacion': 'Vender',
        'puntaje': 85,
      };
    } else if (size > 266000) {
      return {
        'grado': 'B',
        'descripcion': 'La prenda presenta un estado de conservación bueno, con uso moderado pero aún presentable. '
            'Puede ser una gran opción para donarla a quien la necesite.',
        'recomendacion': 'Donar',
        'puntaje': 60,
      };
    } else {
      return {
        'grado': 'C',
        'descripcion': 'La prenda muestra señales de desgaste significativo que dificultan su reutilización directa. '
            'Lo mejor es llevarla a un punto de reciclaje textil.',
        'recomendacion': 'Reciclar',
        'puntaje': 35,
      };
    }
  }
}
