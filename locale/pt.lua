return {
  pt = {
    bad_argument = 'argumento inválido `%{arg}` para %{caller} (%{exp} era esperado, %{got} foi recebido)',
    bad_argument_i = 'argumento inválido #%{arg} para %{caller} (%{exp} era esperado, %{got} foi recebido)',
    nil_argument = 'argumento inválido `%{arg}` para %{caller} (um valor era esperado)',
    nil_argument_i = 'argumento inválido #%{arg} para %{caller} (um valor era esperado)',
    interpreter = {
      invalid_command = 'comando %q inválido',
      invalid_flag = 'opção %q inválida',
      missing_flag_args = 'argumentos insuficientes para opção %q'
    },
    logs = {err = 'ERRO', ok = 'OK'},
    codes = {
      attribute = {
        EARTH = 'TERRA',
        WATER = 'ÁGUA',
        FIRE = 'FOGO',
        WIND = 'VENTO',
        LIGHT = 'LUZ',
        DARK = 'TREVAS',
        DIVINE = 'DIVINO'
      },
      race = {
        WARRIOR = 'Guerreiro',
        SPELLCASTER = 'Mago',
        FAIRY = 'Fada',
        FIEND = 'Demônio',
        ZOMBIE = 'Zumbi',
        MACHINE = 'Máquina',
        AQUA = 'Aqua',
        PYRO = 'Piro',
        ROCK = 'Rocha',
        WINGED_BEAST = 'Besta Alada',
        PLANT = 'Planta',
        INSECT = 'Inseto',
        THUNDER = 'Trovão',
        DRAGON = 'Dragão',
        BEAST = 'Besta',
        BEAST_WARRIOR = 'Besta-Guerreira',
        DINOSAUR = 'Dinossauro',
        FISH = 'Peixe',
        SEA_SERPENT = 'Serpente Marinha',
        REPTILE = 'Réptil',
        PSYCHIC = 'Psíquico',
        DIVINE_BEAST = 'Besta Divina',
        CREATOR_GOD = 'Deus Criador',
        WYRM = 'Wyrm',
        CYBERSE = 'Ciberso',
      },
      type = {
        SPELL = {
          attribute = 'MAGIA',
          label = {
            normal = '<t=2><r=2>[</> Card de Magia <r=2>]</></>',
            other = '<t=2><r=2>[</> Card de Magia    <r=2>]</></>'
          }
        },
        TRAP = {
          attribute = 'ARMADILHA',
          label = {
            normal = '<t=2><r=2>[</> Card de Armadilha <r=2>]</></>',
            other = '<t=2><r=2>[</> Card de Armadilha    <r=2>]</></>'
          }
        },
        NORMAL = 'Normal',
        EFFECT = 'Efeito',
        FUSION = 'Fusão',
        RITUAL = 'Ritual',
        SPIRIT = 'Espírito',
        UNION = 'União',
        GEMINI = 'Gêmeos',
        TUNER = 'Regulador',
        SYNCHRO = 'Sincro',
        TOKEN = 'Ficha',
        FLIP = 'Virar',
        TOON = 'Toon',
        XYZ = 'Xyz',
        PENDULUM = 'Pêndulo',
        LINK = 'Link'
      }
    },
    config = {
      globals = 'Configurações globais:',
      locals = 'Configurações locais:',
      none = 'nenhum(a) %s configurado(a)',
      missing = '%q não foi configurado'
    },
    compose = {
      status = 'Compondo %q com %q...',
      output_conflict = 'a pasta de saída não pode ser a mesma que a pasta das artes',
      unknown_mode = 'modo %q desconhecido',
      decode_fail = 'falha ao decodificar %q: ',
      decoding = 'Decodificando %q...',
      rendering = 'Renderizando %q...',
      printing = 'Imprimindo %q...',
      done = 'Pronto!',
      data_fetcher = {
        no_img_folder = 'está faltando a pasta das imagens',
        closed_db = 'database das cartas inexistente ou fechada',
        read_db_fail = 'falha ao ler a database das cartas'
      },
      decoder = {
        state_key_err = '%s não encontrado nos estados',
        unknown_error = 'erro desconhecido no estado %q',
        error = 'erro no estado %q: ',
        not_layer = 'valor retornado inválido #%{arg} (Layer era esperado, %{got} foi recebido)'
      },
      modes = {
        anime = {
          no_card_type = 'falta o tipo da carta',
        },
        proxy = {
          no_card_type = 'falta o tipo da carta',
          copyright = '<t=2><s=5>©</>%{year}</> %{author}',
          default_author = 'KAZUKI TAKAHASHI',
          typedesc = '<t=2><r=2>[</>%s<r=2>]</></>',
          edition = '1<r=7.2 s=3.6>a</> Edição',
          forbidden = '<t=3>Este card não pode ser colocado no Deck.</>'
        }
      }
    },
    export = {
      status = 'Exportando %q com %q...',
      zip_create_error = 'ao criar o .zip:',
      zip_add_error = {
        one = 'O seguinte arquivo não foi incluído no .zip:',
        other = '%{count} arquivos não foram incluídos no .zip:'
      },
      scan_scripts = 'Procurando por scripts...',
      scan_pics = 'Procurando por imagens de carta...',
      scan_fields = 'Procurando por imagens de campo...',
      file_srcdst = '%q -> %q',
      done = 'Pronto!'
    },
    make = {
      recipe_not_list = '"recipe" deve ser uma lista de nomes de arquivos',
      status = 'Criando a database para %q...',
      done = 'Pronto!',
      data_fetcher = {toml_error = 'ao processar .toml:'},
      encoder = {
        pendulum_effect = 'Efeito de Pêndulo',
        monster_effect = 'Efeito de Monstro',
        flavor_text = 'Texto'
      },
      parser = {cyclic_macro = '%q: macro cíclico, impossível determinar seu valor'},
      writer = {
        create_error = 'erro ao criar .cdb: ',
        write_error = 'erro ao escrever .cdb: ',
        custom_error = 'erro ao escrever tabela custom no .cdb: ',
        clean_error = 'erro ao limpar .cdb: ',
        strings = 'Escrevendo strings.conf...',
        strings_fail = 'falha ao escrever strings.conf'
      }
    },
    new = {
      no_name = 'nenhum nome foi dado ao novo projeto',
      invalid_name = 'nome inválido para o projeto',
      create_folder = 'Criando pasta %q...',
      create_cdb = 'Criando database das cartas...',
      create_config = 'Criando config.toml...',
      config_comment = [[
# Use este arquivo para definir configurações locais para seu projeto.
# Qualquer configuração definida aqui vai tomar precedência sobre as globais.
# As configurações globais podem ser encontradas em `%s`.]],
      done = 'Projeto %q criado com sucesso!'
    },
    sync = {
      status = 'Sincronizando %q e %q para %q...',
      writing_string = 'Escrevendo strings.conf...',
      done = 'Pronto!'
    },
    ygofab = {
      usage = 'Uso:\
  $ ygofab <comando> [opções]\
\
Comandos disponíveis:\
  compose\tGera imagens das cartas\
  config \tMostra as configurações em uso\
  export \tExporta um projeto para um arquivo .zip\
  make   \tConverte cartas descritas em .toml para um .cdb\
  new    \tCria um novo projeto\
  sync   \tCopia os arquivos do projeto para o jogo',
      not_in_project = 'Parece que você não está na pasta de um projeto...',
      invalid_command = 'comando inválido'
    },
    ygopic = {
      usage = 'Uso:\
\
  $ ygopic <modo> <pasta-artes> <database> <pasta-saída> [opções]\
\
Argumentos:\
\
  modo        \tOu `anime` ou `proxy`\
  pasta-artes \tCaminho da pasta contendo artes para as cartas\
  database    \tCaminho para um .cdb descrevendo as cartas\
  pasta-saída \tCaminho da pasta de saída para as imagens geradas\
\
Opções disponíveis:\
\
  --size LxA        \tL e A determinam a largura e a altura das imagens\
                    \tgeradas. Se apenas L ou A for especificado, serão\
                    \tmantidas as proporções. Ex.: `--size 800x` gerará\
                    \timagens com 800px em largura, mantendo a proporção.\
                    \tPor padrão, vale o tamanho original.\
\
  --ext <ext>       \tEspecifica qual formato de imagem será usado,\
                    \tsendo `png`, `jpg` ou `jpeg`. Por padrão, `jpg`.\
\
  --artsize <modo>  \tEspecifica como as artes se encaixam na carta,\
                    \tsendo `cover`, `contain` ou `fill`.\
                    \tPor padrão, `cover`.\
\
  --year <ano>      \tEspecifica o ano a ser usado no modo `proxy`, na\
                    \tlinha do copyright. Por padrão, `1996`\
\
  --author <autor>  \tEspecifica o autor a ser usado no modo `proxy`, na\
                    \tlinha do copyright. Por padrão, `KAZUKI TAKAHASHI`.\
\
  --field           \tSe presente, define que serão gerados planos de fundo\
                    \tpara cartas de campo.\
\
  --color-* <cor>   \tMuda a cor usada para os nomes das cartas no modo\
                    \t`proxy`, de acordo com o tipo da carta (*). <cor>\
                    \tdeve ser uma string em formato hexadecimal.\
                    \tEx.: `--color-effect "#ffffff"` define a cor do nome\
                    \tdos Monstros de Efeito como branco.',
      missing_mode = 'por favor especifique <modo>',
      missing_imgfolder = 'por favor especifique <pasta-artes>',
      missing_cdbfp = 'por favor especifique <database>',
      missing_outfolder = 'por favor especifique <pasta-saída>'
    }
  }
}
