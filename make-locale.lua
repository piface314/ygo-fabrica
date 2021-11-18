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
    cp_error = 'failed to copy %q',
    build = {
      ok = 'YGOFabrica has been succesfully built!',
      dep_error = 'failed to build dependencies',
      luajit_error = 'failed to include LuaJIT files in release',
      vips_error = 'failed to include vips files in release',
      i18n_error = 'failed to adjust i18n module',
      toml_error = 'failed to adjust toml module',
      release_error = 'failed to create release'
    },
    install = {
      ok = 'YGOFabrica has been succesfully installed!',
      bin_error = 'failed to write executable files',
      path_backup_error = 'failed to backup user variable PATH',
      path_backup = 'Previous value of user variable PATH has been written to %s',
      path_error = 'failed to add new value into user variable PATH',
      install_script_error = 'failed to write versions to install script'
    },
    config = {
      ok = 'YGOFabrica has been succesfully configured!',
      error = 'failed to write global configuration file',
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
      dep_error = 'falha ao compilar dependências',
      luajit_error = 'falha ao incluir LuaJIT no lançamento',
      vips_error = 'falha ao incluir vips no lançamento',
      i18n_error = 'falha ao ajustar o módulo i18n',
      toml_error = 'falha ao ajustar o módulo toml',
      release_error = 'falha ao criar o lançamento'
    },
    install = {
      ok = 'YGOFabrica foi instalada com sucesso!',
      bin_error = 'falha ao criar arquivos executáveis',
      path_backup_error = 'falha ao fazer backup da variável de ambiente PATH',
      path_backup = 'Valor prévio da variável de ambiente PATH foi escrito em %s',
      path_error = 'falha ao inserir novo valor na variável PATH',
      install_script_error = 'falha ao escrever versões no script de instalação'
    },
    config = {
      ok = 'YGOFabrica foi configurada com sucesso!',
      error = 'falha ao escrever arquivo de configurações globais',
      comment = {
        header = 'Configurações globais para a YGOFabrica',
        gamedir = 'Defina um ou mais `gamedir`s (pastas do jogo)',
        picset = 'Defina um ou mais `picset`s (conjuntos de imagens)'
      }
    }
  }
}