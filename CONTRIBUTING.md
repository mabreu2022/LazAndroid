# 🤝 Guia de Contribuição — LazDroid

Seja muito bem-vindo! Agradecemos o seu interesse em colaborar com o **LazDroid**.

O objetivo deste projeto é democratizar e elevar o nível do desenvolvimento mobile nativo para desenvolvedores Delphi, Lazarus e Free Pascal, trazendo componentes de nível comercial e uma esteira de deploy ágil em 1-clique.

---

## 🛡️ Política de Aprovação e Fluxo de Governança

Para garantir a estabilidade do compilador, a compatibilidade com a arquitetura **AArch64 (ARM64)** e a integridade da suíte de componentes, o repositório opera sob a seguinte regra:

> ⚠️ **Nenhum commit entra diretamente na branch `main`.**  
> Todas as contribuições devem ser enviadas exclusivamente via **Pull Request (PR)** e passarão obrigatoriamente por **análise e aprovação do mantenedor (@mabreu2022)** antes de serem integradas (*merged*).

---

## 🚀 Passo a Passo para Contribuir

### 1. Faça um Fork do Repositório
No canto superior direito da página do projeto no GitHub ([github.com/mabreu2022/LazAndroid](https://github.com/mabreu2022/LazAndroid)), clique no botão **Fork** para criar uma cópia do projeto na sua conta.

### 2. Clone o seu Fork Localmente
Abra o seu terminal e clone a sua cópia:
```bash
git clone https://github.com/<seu-usuario>/LazAndroid.git
cd LazAndroid
```

### 3. Crie uma Branch para a sua Funcionalidade
Nunca trabalhe diretamente na branch `main`. Crie uma branch com um nome semântico e claro:
```bash
# Para novos componentes ou funcionalidades:
git checkout -b feat/novo-componente-chart

# Para correções de bugs:
git checkout -b fix/ajuste-teclado-virtual

# Para documentação ou exemplos:
git checkout -b docs/exemplo-camera-sqlite
```

### 4. Desenvolva e Respeite as Boas Práticas
Ao escrever ou alterar código Pascal:
- **Modo do Compilador:** Utilize sempre `{$mode ObjFPC}{$H+}` ou `{$mode delphi}` onde compatível.
- **Padrões de Nomenclatura:**
  - Classes iniciam com `T` (ex: `TLazDroidChart`).
  - Atributos privados iniciam com `F` (ex: `FCorFundo`).
  - Parâmetros iniciam com `A` (ex: `AValor`).
- **Touch-First:** Lembre-se de que novos componentes devem possuir áreas de toque confortáveis (mínimo de 44 a 48px).
- **Sem Dependências Pesadas:** Não adicione bibliotecas externas que quebrem a compilação do `ppcrossa64.exe` para Android.

### 5. Validação Local Obrigatória
Antes de enviar seu Pull Request, certifique-se de que:
1. Os pacotes `package/LazDroidDeploy.lpk` e `package/LazDroidControls.lpk` compilam sem erros na sua IDE ou via `lazbuild`.
2. O aplicativo de demonstração (`demo5/project1.lpi` ou `demo/LazAndroidDemo.lpi`) compila com sucesso.
3. Se adicionou um novo componente, certifique-se de adicioná-lo à procedure `Register` em `package/LazDroidMobileControls.pas`.

### 6. Commit e Push
Escreva mensagens de commit claras e objetivas no padrão [Conventional Commits](https://www.conventionalcommits.org/):
```bash
git add .
git commit -m "feat(controls): adicionar componente TLazDroidSegmentedSwitch"
git push origin feat/novo-componente-chart
```

### 7. Abra o Pull Request no GitHub
1. Acesse o repositório oficial [github.com/mabreu2022/LazAndroid](https://github.com/mabreu2022/LazAndroid).
2. Clique no banner verde **"Compare & pull request"**.
3. Preencha o template de Pull Request explicando:
   - Qual problema a alteração resolve.
   - O que foi adicionado/modificado.
   - Quais testes manuais foram feitos (no Windows e/ou celular Android).
4. Submeta o PR.

---

## 🔍 O Processo de Revisão

1. O mantenedor receberá a notificação do seu Pull Request.
2. Comentários ou sugestões de melhorias pontuais poderão ser solicitados nas conversas do PR.
3. Assim que aprovado por **@mabreu2022**, seu código será incorporado à branch `main` e você será listado como contribuidor oficial do LazDroid!

---

## 💡 Ideias de Contribuições Bem-Vindas
- Novos controles mobile (gráficos táteis, carrosséis de imagens, leitor de QR Code / Código de Barras).
- Correções de compatibilidade para versões específicas do Android (Android 14 / 15).
- Melhorias nos exemplos práticos e na documentação.
- Traduções e guias passo a passo adicionais.

Obrigado por ajudar a fortalecer o ecossistema Free Pascal & Lazarus! 🚀
