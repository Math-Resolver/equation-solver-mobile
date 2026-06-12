Para rodar o Backend For Frontend, instale as dependencias do projeto e entre no diretorio `src/presentation.application`.

```bash
pip install -r ../../requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Documentacao OpenAPI: `http://127.0.0.1:8000/docs`

Para testar no Android fisico, use no app o IP local da maquina (ex.: `http://192.168.0.115:8000`) e mantenha celular e computador na mesma rede.

## Endpoints

### `POST /auth/resgister/passkey`

Autenticacao:
- Nao requer token

Resposta de sucesso (`200`):

```json
{
	"ok": true
}
```

### `GET /v1/topics/available`

Autenticacao:
- Requer header `Authorization: Bearer <jwt>`

Resposta de sucesso (`200`):

```json
{
	"topics": [
		"Logarithm",
		"Linear Equations"
	]
}
```

Erros:
- `401 Unauthorized`

### `POST /v1/conversation`

Autenticacao:
- Requer header `Authorization: Bearer <jwt>`

Body:

```json
{
	"topic": "Logarithm"
}
```

Resposta de sucesso (`200`):

```json
{
	"is_operation_successful": true,
	"message": "A logarithm tells which exponent produces a value.",
	"example": "log2(8) = 3 because 2^3 = 8."
}
```

Erros:
- `401 Unauthorized`
- `502 Bad Gateway` quando o provider de IA falha

Cache e integracao:
- O backend consulta Redis antes de chamar o Gemini
- Se o Redis falhar, o fluxo continua via Gemini
- Respostas bem-sucedidas do Gemini sao salvas no cache por TTL

### `POST /v1/equation/solve`

Autenticacao:
- Nao obrigatoria para resolver
- Se enviar `Authorization: Bearer dev-user:<username>`, o historico pode ser persistido em background

Body:

```json
{
	"equation": "2x + 4 = 10",
	"showSteps": true
}
```

Resposta de sucesso (`200`):

```json
{
	"result": "x = 3",
	"steps": [
		{
			"rule": "Subtract 4 from both sides",
			"before": "2x + 4 = 10",
			"after": "2x = 6"
		}
	]
}
```

Erros:
- `400 Bad Request` para entrada invalida ou erro de resolucao
- `499 Client disconnected` quando o cliente desconecta
- `502 Bad Gateway` para tipo de equacao nao suportado

Variaveis de ambiente:
- `REDIS_URL`: URL de conexao do Redis
- `CONVERSATION_CACHE_TTL_SECONDS`: TTL do cache em segundos. Default: `3600`
- `GEMINI_API_KEY`: chave da Gemini Developer API
- `GEMINI_MODEL`: modelo Gemini. Default: `gemini-2.0-flash`
- `GEMINI_TIMEOUT_SECONDS`: timeout da chamada ao Gemini. Default: `10`

## Mock da API no app (sem backend)

O app possui um mock interno para todos os endpoints usados em `auth`, `chat` e `equation solver`.

Ative com:

```bash
flutter run --dart-define=USE_API_MOCK=true
```

### Endpoints mockados

- `POST /v1/auth/login`
- `POST /v1/auth/login/finish`
- `POST /v1/auth/register`
- `POST /v1/auth/register/finish`
- `GET /v1/topics/available`
- `POST /v1/conversation`
- `POST /v1/equation/solve`

### Simular falhas globais ou por endpoint

Use `MOCK_API_SCENARIO` com valores separados por virgula:

```bash
flutter run --dart-define=USE_API_MOCK=true --dart-define=MOCK_API_SCENARIO=auth_401
```

Exemplos de cenarios:

- `auth_401`
- `topics_502`
- `conversation_502`
- `equation_400`
- `equation_502`
- `all_400`
- `all_401`
- `all_502`
- `get:/v1/topics/available:502`
- `post:/v1/equation/solve:400`

Tambem e possivel forcar status por payload (apenas no mock), enviando `__mockStatusCode` no body.

### Simular latencia de backend no mock

O mock ja inclui latencia artificial para parecer backend real.

- `MOCK_API_LATENCY_MS`: latencia base em ms (default: `800`)
- `MOCK_API_LATENCY_JITTER_MS`: variacao aleatoria em ms (default: `400`)

Exemplo com latencia fixa de 800ms:

```bash
flutter run --dart-define=USE_API_MOCK=true --dart-define=MOCK_API_LATENCY_MS=800 --dart-define=MOCK_API_LATENCY_JITTER_MS=0
```

Exemplo com latencia variavel (800ms ate 1200ms):

```bash
flutter run --dart-define=USE_API_MOCK=true --dart-define=MOCK_API_LATENCY_MS=800 --dart-define=MOCK_API_LATENCY_JITTER_MS=400
```


// TODO ALTERAR A MODAL DE ERRO AO ABRIR A CONVERSAR COM O KILLBOT. ESTÁ FORA DOS PADRÕES DO PROJETOZ