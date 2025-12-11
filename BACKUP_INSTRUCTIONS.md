# 📊 Sistema de Backup e Restauração

## Visão Geral

O sistema permite exportar e importar todos os dados da aplicação em formato Excel (.xlsx).

## Como Usar

### 📥 Exportar Dados

1. Acesse a página de configurações: `/settings`
2. Clique em **"📊 Baixar Backup (Excel)"**
3. Um arquivo será baixado com o nome `backup_habitos_YYYYMMDD.xlsx`

### 📤 Importar Dados

⚠️ **ATENÇÃO**: A importação substitui TODOS os dados atuais do usuário!

1. Acesse a página de configurações: `/settings`
2. Na seção "Importar Dados", selecione o arquivo `.xlsx`
3. Clique em **"📥 Importar Backup"**
4. Confirme a ação no diálogo de confirmação

## Estrutura do Arquivo Excel

O arquivo exportado contém 4 abas:

### 1. Habitos
| Coluna | Descrição | Exemplo |
|--------|-----------|---------|
| ID | Identificador único | 1 |
| Nome | Nome do hábito | "Exercício Físico" |
| Descrição | Descrição detalhada | "Fazer 30 minutos de corrida" |
| Dias da Semana | Dias em que o hábito é praticado | "Seg, Ter, Qua, Qui, Sex" |
| Frequência Semanal | Quantas vezes por semana | 5 |
| Ativo | Se o hábito está ativo | "Sim" ou "Não" |
| Tags | Tags associadas | "Saúde, Fitness" |

### 2. Registros
| Coluna | Descrição | Exemplo |
|--------|-----------|---------|
| ID | Identificador único | 1 |
| Hábito ID | ID do hábito relacionado | 1 |
| Hábito Nome | Nome do hábito | "Exercício Físico" |
| Data | Data do registro | "11/12/2025" |
| Concluído | Se foi concluído | "Sim" ou "Não" |
| Observação | Notas adicionais | "Corri 5km" |

### 3. Tags
| Coluna | Descrição | Exemplo |
|--------|-----------|---------|
| ID | Identificador único | 1 |
| Nome | Nome da tag | "Saúde" |
| Cor | Cor em hexadecimal | "#28a745" |

### 4. Habitos_Tags
| Coluna | Descrição | Exemplo |
|--------|-----------|---------|
| Hábito ID | ID do hábito | 1 |
| Tag ID | ID da tag | 1 |

## Mapeamento de Dias da Semana

O sistema usa as seguintes abreviações em português:

- **Dom** = Domingo (Sunday)
- **Seg** = Segunda-feira (Monday)
- **Ter** = Terça-feira (Tuesday)
- **Qua** = Quarta-feira (Wednesday)
- **Qui** = Quinta-feira (Thursday)
- **Sex** = Sexta-feira (Friday)
- **Sab** = Sábado (Saturday)

## Editando o Arquivo Excel

Você pode editar o arquivo Excel antes de reimportá-lo, mas tome cuidado:

### ✅ Pode Fazer:
- Adicionar novos hábitos (com IDs únicos)
- Editar nomes, descrições e observações
- Alterar dias da semana (use as abreviações corretas)
- Adicionar/remover tags
- Modificar cores das tags

### ❌ Não Faça:
- Remover a linha de cabeçalho
- Alterar os nomes das abas
- Usar formatos de data diferentes de DD/MM/YYYY
- Usar valores diferentes de "Sim" ou "Não" nas colunas booleanas
- Deixar células obrigatórias em branco (ID, Nome, Data, etc)

## Tratamento de Erros

Se houver erro na importação:
- A transação será revertida (rollback)
- Seus dados originais permanecerão intactos
- Uma mensagem de erro será exibida

## Dicas de Segurança

1. **Faça backups regulares** - Recomendamos backup semanal
2. **Teste a importação** - Exporte, depois reimporte para garantir que funciona
3. **Guarde múltiplas versões** - Mantenha backups de diferentes datas
4. **Verifique os dados** - Abra o Excel e revise antes de importar

## Compatibilidade

O arquivo Excel exportado é compatível com:
- ✅ Microsoft Excel 2007+
- ✅ Google Sheets
- ✅ LibreOffice Calc
- ✅ Apple Numbers

## Gems Utilizadas

- `caxlsx` - Geração de arquivos Excel
- `caxlsx_rails` - Integração com Rails
- `roo` - Leitura de arquivos Excel
