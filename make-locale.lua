return {
  en = {
    logs = {err = 'ERROR', ok = 'OK'},
    interpreter = {
      invalid_command = 'invalid command %q',
      invalid_flag = 'invalid flag %q',
      missing_flag_args = 'not enough arguments for %q flag'
    },
    missing_command = 'please specify `build`, `install` or `config`',
    mkdir_error = 'failed to create folder %q',
    cp_erroR = 'failed to copy %q',
    build = {
      ok = 'YGOFabrica has been succesfully built!',
      luajit_error = 'failed to include LuaJIT files in release',
      vips_error = 'failed to include vips files in release',
      i18n_error = 'failed to adjust i18n module',
      toml_error = 'failed to adjust toml module',
      release_error = 'failed to create release'
    },
    install = {
      ok = 'YGOFabrica has been succesfully installed!',
      sudo = 'Using sudo to install vips',
      vips_error = 'failed to install vips'
    },
    config = {
      ok = 'YGOFabrica has been succesfully configured!',
      comment = {
        header = 'Global configurations for YGOFabrica',
        gamedir = 'Define one or more `gamedir`s (game directories)',
        picset = 'Define one or more `picset`s (set of card pics)'
      }
    }
  },
  pt = {
    logs = {err = 'ERRO', ok = 'OK'},
    interpreter = {
      invalid_command = 'comando %q inválido',
      invalid_flag = 'opção %q inválida',
      missing_flag_args = 'argumentos insuficientes para opção %q'
    },
    missing_command = 'por favor especifique `build`, `install` ou `config`',
    mkdir_error = 'falha ao criar a pasta %q',
    cp_error = 'falha ao copiar %q',
    build = {
      ok = 'YGOFabrica foi compilada com sucesso!',
      luajit_error = 'falha ao incluir LuaJIT no lançamento',
      vips_error = 'falha ao incluir vips no lançamento',
      i18n_error = 'falha ao ajustar o módulo i18n',
      toml_error = 'falha ao ajustar o módulo toml',
      release_error = 'falha ao criar o lançamento'
    },
    install = {
      ok = 'YGOFabrica foi instalada com sucesso!',
      sudo = 'Usando sudo para instalar vips',
      vips_error = 'falha ao instalar vips'
    },
    config = {
      ok = 'YGOFabrica foi configurada com sucesso!',
      comment = {
        header = 'Configurações globais para a YGOFabrica',
        gamedir = 'Defina um ou mais `gamedir`s (pastas do jogo)',
        picset = 'Defina um ou mais `picset`s (conjuntos de imagens)'
      }
    }
  }
}