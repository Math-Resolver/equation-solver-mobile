import 'dart:async';
import 'dart:math';

import 'http_client_interface.dart';
import 'http_exception.dart';

class MockApiHttpClient implements IHttpClientInterface {
  MockApiHttpClient({
    String scenario = '',
    int latencyMs = 800,
    int latencyJitterMs = 400,
    Random? random,
  }) : _scenarios = scenario
          .split(',')
          .map((item) => item.trim().toLowerCase())
          .where((item) => item.isNotEmpty)
          .toSet(),
       _latencyMs = latencyMs < 0 ? 0 : latencyMs,
       _latencyJitterMs = latencyJitterMs < 0 ? 0 : latencyJitterMs,
       _random = random ?? Random();

  final Set<String> _scenarios;
  final int _latencyMs;
  final int _latencyJitterMs;
  final Random _random;
  final Map<String, int> _exampleRequestCounts = {};

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _simulateLatency();
    _throwIfScenarioError(method: 'GET', path: path);

    switch (path) {
      case '/v1/topics/available':
        return {
          'topics': 
            [
              'Aritmética', 
              'Álgebra', 
              'Frações',
              'Equações do 1º Grau',
              'Equações do 2º Grau',
              'Geometria',
              'Trigonometria',
              'Logaritmos',
              'Probabilidade',
              'Estatística',
              'Cálculo Diferencial',
              'Cálculo Integral'
              ],
        };
      default:
        throw HttpException(statusCode: 404, message: 'Mock route not found');
    }
  }

  @override
  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    await _simulateLatency();

    final statusOverride = _extractStatusOverride(data);
    if (statusOverride != null) {
      throw HttpException(
        statusCode: statusOverride,
        message: 'Forced by request payload',
      );
    }

    _throwIfScenarioError(method: 'POST', path: path);

    switch (path) {
      case '/v1/auth/login':
      case '/v1/auth/register':
        return {
          'challenge': 'mock-challenge-token',
          'relyingParty': {'id': 'killmath', 'name': 'KillMath'},
          'user': {
            'id': 'mock-user-id',
            'name': 'mock-user',
            'displayName': 'Mock User',
          },
        };
      case '/v1/auth/login/finish':
      case '/v1/auth/register/finish':
        final shouldFailAuth = _hasScenario('auth_finish_401');
        if (shouldFailAuth) {
          throw const HttpException(statusCode: 401, message: 'Unauthorized');
        }
        return {
          'access_token': 'mock-access-token',
          'refresh_token': 'mock-refresh-token',
        };
      case '/v1/conversation':
        final topic = _extractString(data, 'topic').trim();
        if (topic.isEmpty) {
          throw const HttpException(
            statusCode: 400,
            message: 'Topic is required',
          );
        }
        return _buildConversationResponse(topic);
      case '/v1/equation/solve':
        final equation = _extractString(data, 'equation').trim();
        if (equation.isEmpty) {
          throw const HttpException(
            statusCode: 400,
            message: 'Equation is required',
          );
        }
        return {
          'result': 'x = 3',
          'steps': [
            {
              'rule': 'Subtract 4 from both sides',
              'before': '2x + 4 = 10',
              'after': '2x = 6',
            },
            {
              'rule': 'Divide both sides by 2',
              'before': '2x = 6',
              'after': 'x = 3',
            },
          ],
        };
      default:
        throw HttpException(statusCode: 404, message: 'Mock route not found');
    }
  }

  Map<String, dynamic> _buildConversationResponse(String topic) {
    final normalizedTopic = _normalizeTopic(topic);

    switch (normalizedTopic) {
      case 'aritmetica':
        return _buildConversationEntry(
          message:
              'A aritmética é a base da matemática para resolver operações básicas como soma, subtração, multiplicação e divisão, ajudando a entender quantidades e cálculos do cotidiano.',
          examples: ['Ex.: 8 + 4 = 12, porque somamos 8 unidades com 4 unidades.', 'Ex.: 15 - 7 = 8, porque tiramos 7 de 15 e sobram 8.'],
          topic: topic,
        );
      case 'algebra':
        return _buildConversationEntry(
          message:
              'A álgebra usa letras para representar valores desconhecidos e transforma problemas em equações, permitindo encontrar soluções de forma organizada.',
          examples: ['Ex.: 2x + 3 = 7 → subtraímos 3 de ambos os lados e depois dividimos por 2, então x = 2.', 'Ex.: 5y - 1 = 14 → somamos 1 aos dois lados e depois dividimos por 5, então y = 3.'],
          topic: topic,
        );
      case 'fracoes':
        return _buildConversationEntry(
          message:
              'Frações representam partes de um inteiro e são úteis para comparar, dividir e medir quantidades que não são inteiras.',
          examples: ['Ex.: 1/2 + 1/4 = 3/4, porque juntamos duas partes de tamanhos diferentes e chegamos a três quartos.', 'Ex.: 2/3 - 1/3 = 1/3, porque retiramos uma terça parte de duas terças partes e sobra uma terça parte.'],
          topic: topic,
        );
      case 'equacoes do 1o grau':
      case 'equacoes do 1º grau':
        return _buildConversationEntry(
          message:
              'As equações do 1º grau têm uma incógnita e podem ser resolvidas passo a passo, isolando a variável para descobrir o valor dela.',
          examples: ['Ex.: 3x + 2 = 11 → subtraímos 2 dos dois lados e depois dividimos por 3, então x = 3.', 'Ex.: 4x - 5 = 7 → somamos 5 aos dois lados e depois dividimos por 4, então x = 3.'],
          topic: topic,
        );
      case 'equacoes do 2o grau':
      case 'equacoes do 2º grau':
        return _buildConversationEntry(
          message:
              'As equações do 2º grau envolvem o termo x² e podem ter até duas soluções diferentes, dependendo dos coeficientes da equação.',
          examples: ['Ex.: x² - 5x + 6 = 0 → os valores que satisfazem a equação são x = 2 ou x = 3.', 'Ex.: x² + 2x - 8 = 0 → as soluções são x = 2 ou x = -4.'],
          topic: topic,
        );
      case 'geometria':
        return _buildConversationEntry(
          message:
              'A geometria estuda formas, medidas, ângulos e posições no espaço, ajudando a calcular áreas, perímetros e propriedades das figuras.',
          examples: ['Ex.: um retângulo de 4 cm por 2 cm tem área 8 cm², porque multiplicamos base pela altura.', 'Ex.: um triângulo de base 6 cm e altura 4 cm tem área 12 cm², usando a fórmula da área do triângulo.'],
          topic: topic,
        );
      case 'trigonometria':
        return _buildConversationEntry(
          message:
              'A trigonometria relaciona ângulos e lados de triângulos, sendo muito usada para medir distâncias e entender relações geométricas.',
          examples: ['Ex.: sen 30° = 1/2, porque no triângulo retângulo esse valor representa a razão entre o cateto oposto e a hipotenusa.', 'Ex.: cos 60° = 1/2, que é outro valor importante dessa relação entre ângulo e lados.'],
          topic: topic,
        );
      case 'logaritmos':
        return _buildConversationEntry(
          message:
              'Os logaritmos são usados para inverter potências e aparecem em problemas de crescimento, escalas e fórmulas científicas.',
          examples: ['Ex.: log₂(8) = 3, porque 2³ = 8.', 'Ex.: log₁₀(100) = 2, porque 10² = 100.'],
          topic: topic,
        );
      case 'probabilidade':
        return _buildConversationEntry(
          message:
              'A probabilidade mede a chance de um evento acontecer e ajuda a analisar situações com incerteza, como jogos, previsões e experimentos.',
          examples: ['Ex.: a chance de sair cara em uma moeda é 1/2, porque há dois resultados possíveis e apenas um é cara.', 'Ex.: a chance de sair um número par em um dado é 1/2, pois há 3 números pares entre 6 possibilidades.'],
          topic: topic,
        );
      case 'estatistica':
        return _buildConversationEntry(
          message:
              'A estatística organiza dados, resume informações e ajuda a identificar padrões, tendências e relações entre valores.',
          examples: ['Ex.: a média de 2, 4 e 6 é 4, porque somamos os valores e dividimos pela quantidade de números.', 'Ex.: a mediana de 1, 3 e 5 é 3, que é o valor central quando os dados estão em ordem.'],
          topic: topic,
        );
      case 'calculo diferencial':
        return _buildConversationEntry(
          message:
              'O cálculo diferencial estuda como grandezas mudam em cada instante e é muito usado para analisar variações e taxas de mudança.',
          examples: ['Ex.: a derivada de x² é 2x, porque a taxa de variação dessa função aumenta proporcionalmente a x.', 'Ex.: a derivada de 3x + 5 é 3, pois a função cresce de forma constante.'],
          topic: topic,
        );
      case 'calculo integral':
        return _buildConversationEntry(
          message:
              'O cálculo integral soma pequenas partes para encontrar áreas, totais e acumulações em funções ao longo de um intervalo.',
          examples: ['Ex.: ∫ x dx = x²/2 + C, que representa a soma acumulada da função x.', 'Ex.: ∫ 2x dx = x² + C, mostrando como a integral devolve a função original, sem a derivada.'],
          topic: topic,
        );
      default:
        return _buildConversationEntry(
          message: 'Mock explanation about $topic.',
          examples: [
            'Mock example for $topic: x + 2 = 5 => x = 3.',
            'Mock alternative example for $topic: 3x = 9 => x = 3.',
          ],
          topic: topic,
        );
    }
  }

  Map<String, dynamic> _buildConversationEntry({
    required String message,
    required List<String> examples,
    required String topic,
  }) {
    return {
      'message': message,
      'example': _pickExample(topic, examples),
    };
  }

  String _pickExample(String topic, List<String> examples) {
    if (examples.isEmpty) {
      return '';
    }

    final normalizedTopic = _normalizeTopic(topic);
    final requestCount = (_exampleRequestCounts[normalizedTopic] ?? 0);
    final index = requestCount < examples.length ? requestCount : examples.length - 1;
    _exampleRequestCounts[normalizedTopic] = requestCount + 1;
    return examples[index];
  }

  String _normalizeTopic(String topic) {
    return topic
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('º', '')
        .replaceAll('°', '');
  }

  void _throwIfScenarioError({required String method, required String path}) {
    final routeKey = '${method.toLowerCase()}:$path';

    if (_hasScenario('all_401') || _hasScenario('$routeKey:401')) {
      throw const HttpException(statusCode: 401, message: 'Unauthorized');
    }
    if (_hasScenario('all_400') || _hasScenario('$routeKey:400')) {
      throw const HttpException(statusCode: 400, message: 'Bad request');
    }
    if (_hasScenario('all_502') || _hasScenario('$routeKey:502')) {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }

    if (_hasScenario('auth_401') && path.startsWith('/v1/auth/')) {
      throw const HttpException(statusCode: 401, message: 'Unauthorized');
    }
    if (_hasScenario('topics_502') && path == '/v1/topics/available') {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }
    if (_hasScenario('conversation_502') && path == '/v1/conversation') {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }
    if (_hasScenario('equation_400') && path == '/v1/equation/solve') {
      throw const HttpException(statusCode: 400, message: 'Bad request');
    }
    if (_hasScenario('equation_502') && path == '/v1/equation/solve') {
      throw const HttpException(statusCode: 502, message: 'Bad gateway');
    }
  }

  bool _hasScenario(String value) => _scenarios.contains(value.toLowerCase());

  int? _extractStatusOverride(Object? data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }
    final status = data['__mockStatusCode'];
    if (status is int) {
      return status;
    }
    if (status is String) {
      return int.tryParse(status);
    }
    return null;
  }

  String _extractString(Object? data, String key) {
    if (data is! Map<String, dynamic>) {
      return '';
    }
    return (data[key] ?? '').toString();
  }

  Future<void> _simulateLatency() {
    final jitter = _latencyJitterMs > 0
        ? _random.nextInt(_latencyJitterMs + 1)
        : 0;
    final totalDelayMs = _latencyMs + jitter;
    if (totalDelayMs <= 0) {
      return Future<void>.value();
    }
    return Future<void>.delayed(Duration(milliseconds: totalDelayMs));
  }
}