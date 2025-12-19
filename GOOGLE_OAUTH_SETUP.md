# Configuração do Google OAuth2

Este documento explica como configurar o login com Google OAuth2 para a aplicação habi.my.

## O que foi implementado

✅ Gems instaladas: `omniauth-google-oauth2` e `omniauth-rails_csrf_protection`
✅ Migration para adicionar campos `provider` e `uid` ao modelo User
✅ Configuração do Devise com OmniAuth
✅ Controller de callbacks para processar login do Google
✅ Botões "Continuar com Google" nas páginas de login e cadastro
✅ Estilização CSS para os botões OAuth
✅ Trial automático de 7 dias para novos usuários via Google

## Como configurar as credenciais do Google

### 1. Criar projeto no Google Cloud Console

1. Acesse: https://console.cloud.google.com/
2. Crie um novo projeto ou selecione um existente
3. No menu lateral, vá em **APIs & Services** > **Credentials**

### 2. Configurar OAuth Consent Screen

1. Clique em **OAuth consent screen** (tela de consentimento)
2. Selecione **External** (externo) e clique em **Create**
3. Preencha as informações obrigatórias:
   - **App name**: habi.my
   - **User support email**: seu email
   - **Developer contact information**: seu email
4. Clique em **Save and Continue**
5. Na seção **Scopes**, clique em **Add or Remove Scopes** e adicione:
   - `userinfo.email`
   - `userinfo.profile`
6. Clique em **Save and Continue**
7. Em **Test users**, adicione seu email (se ainda estiver em modo de teste)
8. Clique em **Save and Continue** e depois **Back to Dashboard**

### 3. Criar credenciais OAuth 2.0

1. Clique em **Credentials** > **Create Credentials** > **OAuth client ID**
2. Selecione **Application type**: **Web application**
3. Preencha:
   - **Name**: habi.my OAuth Client
   - **Authorized JavaScript origins**:
     - `http://localhost:3000` (desenvolvimento)
     - `https://seu-dominio.com` (produção)
   - **Authorized redirect URIs**:
     - `http://localhost:3000/users/auth/google_oauth2/callback` (desenvolvimento)
     - `https://seu-dominio.com/users/auth/google_oauth2/callback` (produção)
4. Clique em **Create**
5. **IMPORTANTE**: Copie o **Client ID** e **Client secret** que aparecerão

### 4. Adicionar credenciais ao Rails

Execute o comando abaixo para editar as credenciais criptografadas:

```bash
EDITOR="code --wait" rails credentials:edit
```

Ou, se preferir outro editor:

```bash
EDITOR="notepad" rails credentials:edit
```

Adicione as credenciais do Google no seguinte formato:

```yaml
google:
  client_id: SEU_CLIENT_ID_AQUI
  client_secret: SEU_CLIENT_SECRET_AQUI
```

Salve e feche o arquivo. O Rails irá criptografar automaticamente.

### 5. Verificar se está funcionando

1. Reinicie o servidor Rails:
   ```bash
   rails server
   ```

2. Acesse a página de login: `http://localhost:3000/users/sign_in`
3. Clique em "Continuar com Google"
4. Você deve ser redirecionado para a tela de login do Google

## Como funciona

### Fluxo de autenticação

1. Usuário clica em "Continuar com Google"
2. É redirecionado para o Google para fazer login
3. Google pede permissão para compartilhar email e perfil
4. Após aceitar, Google redireciona para `/users/auth/google_oauth2/callback`
5. O controller `Users::OmniauthCallbacksController` processa:
   - Se o usuário já existe (mesmo `provider` e `uid`), faz login
   - Se é novo, cria o usuário automaticamente com:
     - Email do Google
     - Senha aleatória segura (gerada pelo Devise)
     - Trial de 7 dias automático
6. Usuário é redirecionado para o dashboard

### Integração com sistema de Trial

Usuários que entram via Google recebem automaticamente:
- 7 dias de trial gratuito
- Acesso às funcionalidades premium durante o trial
- Possibilidade de upgrade via Stripe posteriormente

### Conta duplicada (Google + Email/Senha)

**Importante**: Se um usuário já criou conta com email/senha e depois tenta entrar via Google com o MESMO email, serão criadas **duas contas separadas**.

Para unificar contas no futuro, você pode adicionar lógica no `User.from_omniauth` para:
1. Buscar usuário por email primeiro
2. Se existir, atualizar `provider` e `uid` na conta existente
3. Se não existir, criar nova conta

Exemplo de código para unificar (opcional):

```ruby
def self.from_omniauth(auth)
  # Primeiro tenta encontrar por provider/uid (conta Google existente)
  user = where(provider: auth.provider, uid: auth.uid).first

  # Se não encontrar, tenta por email (pode ser conta tradicional)
  user ||= where(email: auth.info.email).first

  if user
    # Atualiza provider/uid se for conta tradicional sendo linkada
    user.update(provider: auth.provider, uid: auth.uid) unless user.provider
    user
  else
    # Cria novo usuário
    create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.provider = auth.provider
      user.uid = auth.uid
    end
  end
end
```

## Troubleshooting

### Erro: "redirect_uri_mismatch"

- Certifique-se de que a URI de callback está exatamente igual no Google Console
- Formato: `http://localhost:3000/users/auth/google_oauth2/callback`

### Erro: "invalid_client"

- Verifique se o Client ID e Client Secret estão corretos em `credentials.yml.enc`
- Confirme que executou `rails credentials:edit` e salvou corretamente

### Erro: "Access blocked: This app's request is invalid"

- Configure a OAuth Consent Screen no Google Cloud Console
- Adicione os scopes `userinfo.email` e `userinfo.profile`

### O botão do Google não aparece

- Verifique se adicionou os estilos CSS em `auth.css`
- Certifique-se de que o servidor Rails foi reiniciado

## Segurança

- ✅ CSRF protection habilitado via `omniauth-rails_csrf_protection`
- ✅ Credenciais criptografadas em `credentials.yml.enc`
- ✅ Senhas geradas aleatoriamente para contas OAuth
- ✅ Validação de provider e uid únicos no banco de dados

## Próximos passos (opcional)

- [ ] Adicionar foto do perfil do Google ao usuário
- [ ] Permitir vincular/desvincular conta Google de uma conta existente
- [ ] Adicionar mais providers (Facebook, GitHub, etc.)
- [ ] Implementar login via Apple (Sign in with Apple)

## Suporte

Se tiver problemas, verifique:
1. Logs do Rails: `tail -f log/development.log`
2. Console do navegador (F12) para erros JavaScript
3. Google Cloud Console > Logs para ver callbacks do Google
