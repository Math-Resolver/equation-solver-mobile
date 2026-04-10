# Guia do Projeto

## 🧪 Desenvolvimento Orientado a Testes (TDD)

Este projeto segue a metodologia **TDD (Test-Driven Development)**.

### 🔁 Ciclo TDD

O desenvolvimento deve seguir o ciclo:

1. 🔴 **Red**
   - Escrever um teste que falha
2. 🟢 **Green**
   - Implementar o mínimo necessário para passar no teste
3. 🔵 **Refactor**
   - Melhorar o código mantendo os testes passando

### 📌 Regras

- Nenhuma feature deve ser implementada sem um teste primeiro
- Testes devem validar comportamento, não implementação
- Código deve ser escrito com foco em testabilidade
- Evitar dependências diretas (usar abstrações/interfaces)

### 🧩 Aplicação no Projeto

#### Equation Solver
- Testar:
  - Parsing de equações
  - Regras matemáticas
  - Casos de erro

  ### 🛠️ Ferramentas

- `flutter_test`
- `mocktail`

## 📱 Visão Geral
Este é um aplicativo Flutter chamado **Equation Solver Mobile**, focado em resolver equações matemáticas com suporte a câmera e chat assistido.

O projeto segue uma arquitetura modular baseada em **features**, com separação clara entre:
- apresentação (UI)
- lógica
- acesso a dados

---

## 🏗️ Estrutura do Projeto
```
lib/
├── drawables/ # Constantes visuais (cores, temas)
├── features/
│ ├── chat_assistant/ # Funcionalidade de chat
│ └── equation_solver/ # Funcionalidade principal
│ ├── presentation/
│ │ ├── calculator/
│ │ └── camera/
│ └── repository/
├── main.dart # Entry point
├── routes.dart # Navegação
└── dependencies.dart # Injeção de dependências
```
## 🧩 Arquitetura

O projeto segue princípios de:

- **Feature-first architecture**
- **Separação por camadas**
- **Baixo acoplamento e alta coesão**
- **Interfaces para repositórios**

#### 🎨 Presentation
- Contém UI (widgets, pages)
- Não deve conter lógica de negócio complexa

#### 📦 Repository
- Abstrai acesso a dados
- Define interfaces (`*_interface.dart`)
- Implementações (`*_impl.dart`)

## 📌 Convenções

### 📁 Organização
- Cada feature deve ser isolada dentro de `features/`
- Subpastas devem seguir:
  - `presentation/`
  - `repository/`

### 🧾 Nomenclatura
- Arquivos: `snake_case.dart`
- Classes: `PascalCase`
- Métodos/variáveis: `camelCase`

## 🔌 Injeção de Dependência

Centralizada em:
```
lib/dependencies.dart
```

Regras:
- Sempre registrar interfaces + implementações
- Evitar instanciar classes diretamente na UI

## 🔀 Navegação

Centralizada em:
```
lib/routes.dart
```

Regras:
- Todas as rotas devem ser registradas aqui
- Evitar navegação hardcoded


## ⚙️ Boas Práticas

- Evitar lógica dentro de Widgets
- Usar interfaces para desacoplamento
- Manter funções pequenas e testáveis
- Evitar dependências globais desnecessárias