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
    zip = {missing = '%q: nenhum arquivo nesse caminho'},
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
        CYBERSE = 'Ciberso'
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
        anime = {no_card_type = 'falta o tipo da carta'},
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
      parser = {
        cyclic_macro = '%q: macro cíclico, impossível determinar seu valor'
      },
      writer = {
        create_error = 'erro ao criar .cdb: ',
        write_error = 'erro ao escrever .cdb: ',
        custom_error = 'erro ao escrever tabela custom no .cdb: ',
        clean_error = 'erro ao limpar .cdb: ',
        strings = 'Escrevendo strings.conf...',
        strings_fail = 'falha ao escrever strings.conf',
        no_data = 'não há dados para escrever o .cdb',
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
      path_empty = 'Caminho do gamedir está vazio',
      writing_string = 'Escrevendo strings.conf...',
      done = 'Pronto!'
    },
    ygofab = {
      usage = {
        header = 'Uso:',
        cmd = '$ ygofab <comando> [opções]',
        commands = {
          header = 'Comandos disponíveis:',
          cmd1 = {id = 'compose', desc = [[Gera imagens das cartas.]]},
          cmd2 = {id = 'config', desc = [[Mostra as configurações em uso.]]},
          cmd3 = {id = 'export', desc = [[Exporta um projeto para um arquivo .zip.]]},
          cmd4 = {id = 'make', desc = [[Converte cartas descritas em .toml para um .cdb.]]},
          cmd5 = {id = 'new', desc = [[Cria um novo projeto, dado um nome.]]},
          cmd6 = {id = 'sync', desc = [[Copia os arquivos do projeto para o jogo.]]}
        },
        more = 'Para mais informações, vá em https://github.com/piface314/ygo-fabrica/wiki'
      },
      not_in_project = 'Parece que você não está na pasta de um projeto...',
      invalid_command = 'comando inválido'
    },
    ygopic = {
      usage = {
        header = 'Uso:',
        cmd = '$ ygopic <modo> <pasta-artes> <database> <pasta-saída> [opções]',
        help = '(use --help para mais detalhes)',
        arguments = {
          header = 'Argumentos:',
          arg1 = {id = 'modo', desc = 'Ou `anime` ou `proxy`.'},
          arg2 = {
            id = 'pasta-artes',
            desc = 'Caminho da pasta contendo artes para as cartas.'
          },
          arg3 = {
            id = 'database',
            desc = 'Caminho para um .cdb descrevendo as cartas.'
          },
          arg4 = {
            id = 'pasta-saída',
            desc = 'Caminho da pasta de saída para as imagens geradas.'
          }
        },
        options = {
          header = 'Opções disponíveis:',
          opt1 = {
            label = '--size <L>x<A>',
            desc = [[L e A determinam a largura e a altura das imagens geradas. Se apenas L ou A for especificado, serão mantidas as proporções. Ex.: `--size 800x` gerará imagens com 800px em largura, mantendo a proporção. Por padrão, vale o tamanho original.]]
          },
          opt2 = {
            label = '--ext <ext>',
            desc = [[Especifica qual formato de imagem será usado, sendo `png`, `jpg` ou `jpeg`. Por padrão, `jpg`.]]
          },
          opt3 = {
            label = '--artsize <modo>',
            desc = [[Especifica como as artes se encaixam na carta, sendo `cover`, `contain` ou `fill`. Por padrão, `cover`.]]
          },
          opt4 = {
            label = '--year <ano>',
            desc = [[Especifica o ano a ser usado no modo `proxy`, na linha do copyright. Por padrão, `1996`]]
          },
          opt5 = {
            label = '--author <autor>',
            desc = [[Especifica o autor a ser usado no modo `proxy`, na linha do copyright. Por padrão, `KAZUKI TAKAHASHI`.]]
          },
          opt6 = {
            label = '--field',
            desc = [[Se presente, define que serão gerados planos de fundo para cartas de campo.]]
          },
          opt7 = {
            label = '--color-* <cor>',
            desc = [[Muda a cor usada para os nomes das cartas no modo `proxy`, de acordo com o tipo da carta (*). <cor> deve ser uma string em formato hexadecimal. Ex.: `--color-effect "#ffffff"` define a cor do nome dos Monstros de Efeito como branco.]]
          },
          opt8 = {
            label = '--locale <locale>',
            desc = [[Define qual idioma será usado no texto das cartas. Se não for definido, o idioma da interface será usado.]]
          },
          opt9 = {
            label = '--holo (true|false)',
            desc = [[Define se o holograma deve ser colocado no modo `proxy`. Se não for especificado ou se for `true`, o holograma é colocado. Se for definido para `false`, o holograma não é colocado.]]
          }
        }
      },
      missing_mode = 'por favor especifique <modo>',
      missing_imgfolder = 'por favor especifique <pasta-artes>',
      missing_cdbfp = 'por favor especifique <database>',
      missing_outfolder = 'por favor especifique <pasta-saída>'
    }
  }
}
