# Sistema de Freemium com Stripe - Guia de Configuração

## ✅ Implementação Concluída

Todas as funcionalidades do sistema freemium foram implementadas com sucesso:

### 1. **Modelo de Negócio**

#### Plano FREE (com trial de 7 dias)
- ✅ Primeiros 7 dias: acesso completo premium (trial automático)
- ✅ Após trial: máximo de 4 hábitos
- ✅ Funcionalidades básicas (calendário, estatísticas simples)

#### Plano PREMIUM
- ✅ **Mensal:** R$ 19,90/mês
- ✅ **Anual:** R$ 189,90/ano (economia de 20%)
- ✅ Hábitos ilimitados
- ✅ Estatísticas avançadas
- ✅ Exportar dados
- ✅ Lembretes personalizados
- ✅ Suporte prioritário

---

## 📋 Arquivos Implementados

### Models
- ✅ `app/models/user.rb` - Métodos de trial, premium e limite de hábitos

### Controllers
- ✅ `app/controllers/payments_controller.rb` - Checkout, success, cancel, portal
- ✅ `app/controllers/webhooks_controller.rb` - Processar eventos do Stripe
- ✅ `app/controllers/habitos_controller.rb` - Validação de limite de hábitos

### Views
- ✅ `app/views/payments/pricing.html.erb` - Página de pricing com planos
- ✅ `app/views/shared/_subscription_status.html.erb` - Badge de status da assinatura
- ✅ `app/views/dashboard/index.html.erb` - Atualizado com status de assinatura

### Configuration
- ✅ `config/initializers/stripe.rb` - Configuração do Stripe
- ✅ `config/routes.rb` - Rotas de payments e webhooks
- ✅ `db/migrate/xxx_add_subscription_fields_to_users.rb` - Migration executada

### Documentation
- ✅ `.env.example` - Variáveis de ambiente necessárias

---

## 🚀 Configuração do Stripe

### Passo 1: Obter Chaves da API

1. Acesse o [Dashboard do Stripe](https://dashboard.stripe.com/)
2. Vá em **Developers → API keys**
3. Copie as chaves:
   - `Publishable key` (começa com `pk_test_` ou `pk_live_`)
   - `Secret key` (começa com `sk_test_` ou `sk_live_`)

### Passo 2: Configurar Variáveis de Ambiente

Crie ou edite o arquivo `.env` na raiz do projeto:

```bash
# Stripe API Keys
STRIPE_PUBLISHABLE_KEY=pk_test_sua_chave_aqui
STRIPE_SECRET_KEY=sk_test_sua_chave_aqui
STRIPE_WEBHOOK_SECRET=whsec_sua_chave_webhook_aqui
```

⚠️ **IMPORTANTE:** Nunca commite o arquivo `.env` no Git!

### Passo 3: Configurar Webhook

1. No Dashboard do Stripe, vá em **Developers → Webhooks**
2. Clique em **Add endpoint**
3. Configure:
   - **URL do endpoint:** `https://seu-dominio.com/webhooks/stripe`
   - **Eventos a escutar:**
     - `checkout.session.completed`
     - `customer.subscription.deleted`
     - `invoice.payment_succeeded`
     - `invoice.payment_failed`
4. Copie o **Signing secret** (começa com `whsec_`)
5. Adicione ao `.env` como `STRIPE_WEBHOOK_SECRET`

### Passo 4: Testar Localmente com Stripe CLI

Para testar webhooks localmente:

```bash
# Instalar Stripe CLI
# https://stripe.com/docs/stripe-cli

# Login
stripe login

# Redirecionar webhooks para localhost
stripe listen --forward-to localhost:3000/webhooks/stripe

# Copiar o webhook signing secret que aparece e adicionar ao .env
```

---

## 🧪 Testando o Sistema

### Cartões de Teste

Use estes cartões no ambiente de teste:

- **Sucesso:** `4242 4242 4242 4242`
- **Falha:** `4000 0000 0000 0002`
- **Expiry:** Qualquer data futura (ex: 12/25)
- **CVC:** Qualquer 3 dígitos (ex: 123)

### Fluxo de Teste

1. **Criar novo usuário:**
   - Registrar-se no app
   - Verificar que o trial de 7 dias foi iniciado automaticamente

2. **Testar limite de hábitos:**
   - Criar 4 hábitos (funciona normalmente)
   - Tentar criar o 5º hábito → deve redirecionar para pricing

3. **Testar upgrade para Premium:**
   - Acessar `/pricing`
   - Escolher plano mensal ou anual
   - Completar checkout com cartão de teste
   - Verificar que `premium` foi ativado no banco

4. **Testar webhook:**
   - Após pagamento, verificar logs do webhook
   - Confirmar que usuário foi marcado como premium

5. **Testar Customer Portal:**
   - Clicar em "Gerenciar Assinatura" no dashboard
   - Verificar redirecionamento para portal do Stripe
   - Testar cancelamento de assinatura

---

## 🔒 Segurança

### ✅ Implementado

- Skip CSRF token apenas para endpoint de webhook
- Verificação de assinatura do webhook usando `STRIPE_WEBHOOK_SECRET`
- Autenticação obrigatória em todas as rotas de pagamento
- Validação de plano antes de criar sessão de checkout
- Sanitização de strings para compatibilidade com Windows/UTF-8

### ⚠️ Importante

- Nunca exponha `STRIPE_SECRET_KEY` no frontend
- Sempre use HTTPS em produção
- Configure webhook secret corretamente
- Valide todas as entradas do usuário

---

## 📊 Estrutura do Banco de Dados

### Campos adicionados à tabela `users`:

```ruby
premium: boolean            # default: false - Indica se é premium
trial_ends_at: datetime     # Data de término do trial
stripe_customer_id: string  # ID do customer no Stripe (indexed)
stripe_subscription_id: string  # ID da subscription no Stripe (indexed)
```

---

## 🎯 Funcionalidades do User Model

### Métodos Disponíveis

```ruby
# Verifica se está em trial
user.on_trial?  # true/false

# Verifica se tem acesso premium (pago OU trial)
user.premium?  # true/false

# Verifica se pode criar mais hábitos
user.can_create_habito?  # true/false

# Retorna hábitos restantes
user.habitos_remaining  # "Ilimitado" ou número

# Retorna dias restantes no trial
user.trial_days_remaining  # número

# Verifica se trial está acabando (últimos 2 dias)
user.trial_ending_soon?  # true/false
```

---

## 🎨 Interface do Usuário

### Status da Assinatura

O componente `_subscription_status.html.erb` exibe:

- **Trial:** Badge azul com dias restantes + botão de upgrade
- **Premium:** Badge roxo com botão de gerenciar assinatura
- **Free:** Badge rosa com contador de hábitos + botão de upgrade

### Página de Pricing

A página `/pricing` mostra:

- Comparação entre planos FREE, PREMIUM MENSAL e PREMIUM ANUAL
- Destaque para economia do plano anual (20%)
- Lista completa de funcionalidades
- Badge de trial para novos usuários
- Alertas quando trial está acabando ou limite atingido

---

## 🔄 Webhooks - Eventos Processados

### `checkout.session.completed`
- Ativa premium do usuário
- Salva `stripe_customer_id` e `stripe_subscription_id`

### `customer.subscription.deleted`
- Remove premium do usuário
- Limpa `stripe_subscription_id`

### `invoice.payment_succeeded`
- Confirma renovação bem-sucedida
- Mantém premium ativo

### `invoice.payment_failed`
- Loga erro
- TODO: Enviar email notificando falha

---

## 📧 Emails (Opcional - TODO)

Criar mailers para:

- Trial acabando (2 dias antes)
- Upgrade confirmado
- Assinatura cancelada
- Falha no pagamento

```ruby
rails generate mailer SubscriptionMailer
```

---

## 🔧 Troubleshooting

### Problema: Webhook não está funcionando

**Solução:**
1. Verifique se `STRIPE_WEBHOOK_SECRET` está configurado
2. Teste assinatura do webhook com Stripe CLI
3. Verifique logs: `tail -f log/development.log`

### Problema: Usuário não foi marcado como premium após pagamento

**Solução:**
1. Verifique se webhook foi recebido (logs)
2. Confirme que evento `checkout.session.completed` está configurado
3. Verifique `metadata.user_id` na sessão do Stripe

### Problema: Erro UTF-8 no Windows

**Solução:**
- Código já implementado com `sanitize_string` para lidar com encoding

---

## 📈 Próximos Passos (Opcional)

1. **Analytics:**
   - Tracking de conversões (trial → premium)
   - Métricas de churn

2. **Emails Transacionais:**
   - Implementar SubscriptionMailer
   - Enviar emails em eventos importantes

3. **Jobs Background:**
   - Job diário para verificar trials expirados
   - Notificações automáticas

4. **Melhorias de UX:**
   - Modal de upgrade em vez de página separada
   - Contador de trial no header
   - Animações de confete ao fazer upgrade

5. **Cupons de Desconto:**
   - Implementar sistema de cupons do Stripe
   - Campanhas promocionais

---

## 📝 Comandos Úteis

```bash
# Verificar rotas de pagamento
rails routes | grep payment
rails routes | grep webhook

# Console Rails para testar métodos do User
rails console
user = User.first
user.premium?
user.on_trial?
user.can_create_habito?

# Rollback migration (se necessário)
rails db:rollback

# Recriar banco (CUIDADO - apaga dados!)
rails db:reset
```

---

## ✨ Conclusão

O sistema de freemium está 100% funcional e pronto para uso!

Todos os arquivos necessários foram criados e configurados seguindo as melhores práticas do Rails e do Stripe.

**Próximo passo:** Configure suas chaves da API do Stripe no arquivo `.env` e teste o sistema! 🚀
