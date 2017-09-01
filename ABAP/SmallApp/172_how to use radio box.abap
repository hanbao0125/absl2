parameters: p_add_a radiobutton group 1 default 'X'
           ,p_add_i radiobutton group 1
           ,p_del radiobutton group 1
           .

data: ls_env type apid_env.

clear ls_env.
if p_add_a = 'X'.
  ls_env-mandt = sy-mandt.
  ls_env-id = 'CUALOCALUSER'.
  ls_env-value = 'T'.
  modify apid_env from ls_env.
elseif p_add_i = 'X'.
  ls_env-mandt = sy-mandt.
  ls_env-id = 'CUALOCALUSER'.
  ls_env-value = 'F'.
  modify apid_env from ls_env.
elseif p_del = 'X'.
  ls_env-mandt = sy-mandt.
  ls_env-id = 'CUALOCALUSER'.
  delete apid_env from ls_env.
endif.