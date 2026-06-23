[![CI](https://github.com/Math-Resolver/equation-solver-mobile/actions/workflows/build.yml/badge.svg)](https://github.com/Math-Resolver/equation-solver-mobile/actions/workflows/build.yml)

# equation_solver_mobile

A new Flutter project.

# Getting Started

## IOS Development

Enter in directory of ios:
```
cd ios
```

and run `flutter run`

## Android Development

Enter in directory of android:
```
cd android
```

and run `flutter run`

# To create a new package:

Enter in directory `/packages` and run:
```
flutter create template=package package_name
```


O mock ja inclui latencia artificial para parecer backend real.

- MOCK_API_LATENCY_MS: latencia base em ms (default: 800)
- MOCK_API_LATENCY_JITTER_MS: variacao aleatoria em ms (default: 400)

Exemplo com latencia fixa de 800ms:

```bash
flutter run --dart-define=USE_API_MOCK=true --dart-define=MOCK_API_LATENCY_MS=800 --dart-define=MOCK_API_LATENCY_JITTER_MS=0
```

Exemplo com latencia variavel (800ms ate 1200ms):

```bash
flutter run --dart-define=USE_API_MOCK=true --dart-define=MOCK_API_LATENCY_MS=800 --dart-define=MOCK_API_LATENCY_JITTER_MS=400
```
